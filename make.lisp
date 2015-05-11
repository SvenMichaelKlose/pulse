(defconstant +make-wav?+ nil)

(defvar *tape-loader-start* #x1e00)
(defvar *pulse-short* #x20)
(defvar *pulse-long* #x40)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(load "tape-loader/bin2pottap.lisp")
(load "spinoffs/wav2pwm.lisp")
(load "spinoffs/make-video.lisp")
(load "game/files.lisp")
(load "game/story.lisp")

(defun make-wav (name file gain bass)
  (sb-ext:run-program "/usr/bin/mplayer"
    (list "-vo" "null" "-vc" "null" "-ao" (+ "pcm:fast:file=obj/" name ".wav") file))
  (sb-ext:run-program "/usr/bin/sox"
    (list (+ "obj/" name ".wav")
          (+ "obj/" name "_filtered.wav")
          "bass" bass
          "lowpass" "2000"
          "compand" "0.3,1" "6:-70,-60,-20" "-5" "-90" "0.2" "gain" gain)))

(defun make-conversion (name tv)
  (sb-ext:run-program "/usr/bin/sox"
    (list (+ "obj/" name "_filtered.wav")
          "-c" "1"
          "-b" "16"
          "-r" (princ (pwm-pulse-rate tv) nil)
          (+ "obj/" name "_downsampled_" (downcase (symbol-name tv)) ".wav"))))

(defun make-audio (name file gain bass)
  (make-wav name file gain bass)
  (make-conversion name :pal)
  (make-conversion name :ntsc))

(make-audio "ohne_dich" "spinoffs/ohne_dich.mp3" "4" "-56")
(make-audio "mario" "spinoffs/mario.flv" "4" "-56")

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-output-file in   in-file
                          out  out-file
    (tap2wav in out)))

(defun make (to files cmds)
  (apply #'assemble-files to files)
  (make-vice-commands cmds))

(defun make-game (tape? cmds)
  (make (? tape?
           "obj/game.bin"
           "pulse.prg")
        (+ (& tape?
              (list "game/no-loader.asm"))
           (@ [+ "bender/vic-20/" _]
              `(,@(unless tape?
                    (list "basic-loader.asm"))
                "vic.asm"))
           (@ [+ "game/" _] +pulse-files+))
        cmds))

(defun make-loader-bin ()
  (make "obj/loader.bin"
        '("primary-loader/zeropage.asm"
          "bender/vic-20/vic.asm"
          "bender/vic-20/via.asm"
          "tape-loader/loader.asm"
          "tape-loader/start.asm"
          "primary-loader/waiter.asm")
        "obj/loader.bin.vice.txt"))

(defun make-loader-prg ()
  (make "obj/loader.prg"
        '("bender/vic-20/basic-loader.asm"
          "bender/vic-20/vic.asm"
          "primary-loader/zeropage.asm"
          "primary-loader/main.asm")
        "obj/loader.prg.vice.txt"))

(defun make-ohne-dich-prg (name tv)
  (make (+ "obj/" name "_" tv ".prg")
        `("bender/vic-20/basic-loader.asm"
          "bender/vic-20/vic.asm"
          "spinoffs/start.asm"
          "spinoffs/tape_audio_player.asm"
          ,(+ "spinoffs/text_" name ".asm"))
        (+ "obj/" name "_" tv ".prg.vice.txt")))

(defvar *game-start* nil)
(defvar loaded_tape_loader nil)
(defvar waiter nil)
(defvar waiter_end nil)
(defvar run nil)

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

(defun make-all-games ()
  (make-game nil "obj/pulse.vice.txt")
  (make-game t "obj/game.vice.txt")
  (= *game-start* (get-label 'main))
  (sb-ext:run-program "exomizer" '("sfx" "sys" "-t" "20" "-x" "3" "-o" "obj/game.crunched.prg"  "pulse.prg"))
  (sb-ext:run-program "exomizer" '("sfx" "sys" "-t" "20" "-x" "3" "-o" "pulse.prg"  "pulse.prg"))

  (make-loader-bin)
  (= loaded_tape_loader (get-label 'loaded_tape_loader))
  (= tape_loader_start (get-label 'tape_loader_start))
  (= waiter (get-label 'waiter))
  (= waiter_end (get-label 'waiter_end))
  (= run (get-label 'run))
  (make-loader-prg)

  (with-output-file o "compiled/pulse.tap"
    (write-tap o
        (+ (bin2cbmtap (cddr (string-list (fetch-file "obj/loader.prg")))
                       (+ (padded-name "PULSE")
                          (fetch-file "obj/loader.bin"))
                       :start #x1001)
           (bin2pottap (string-list (fetch-file "obj/game.crunched.prg"))))))

  (when +make-wav?+
    (make-tape-wav "compiled/pulse.tap" "compiled/pulse.tape.wav")))

(defvar *tv* nil)
(defvar ohne_dich nil)
(defvar text nil)

(defun make-ohne-dich (name tv)
  (= *tv* tv)
  (alet (downcase (symbol-name tv))
    (let tapname (+ "compiled/" name "_" ! ".tap")
      (make-ohne-dich-prg name !)
      (make-vice-commands (+ "compiled/" name "_" ! ".vice.txt"))
      (with-output-file o tapname
        (write-tap o
            (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/" name "_" ! ".prg"))))
                        name
                        :start #x1001))
        (? *video?*
           (with-input-file video "nipkow.dat"
             (wav2pwm o (+ "obj/" name "_downsampled_" ! ".wav") video))
           (wav2pwm o (+ "obj/" name "_downsampled_" ! ".wav"))))
      (sb-ext:run-program "/usr/bin/zip" (list (+ tapname ".zip") tapname))
      (when +make-wav?+
        (alet (+ tapname ".wav")
          (make-tape-wav tapname !)
          (sb-ext:run-program "/usr/bin/zip" (list (+ ! ".zip") !)))))))

(make-all-games)

(when *video?*
  (sb-ext:run-program "/usr/bin/mplayer" '("-ao" "dummy" "-vo" "pnm" "-vf" "scale=64:48" "-endpos" "120" "video.mp4")))

(make-ohne-dich "ohne_dich" :pal)
(make-ohne-dich "ohne_dich" :ntsc)
(make-ohne-dich "mario" :pal)
(make-ohne-dich "mario" :ntsc)
(print-pwm-info)

(defun tap-rate (tv avg-len)
  ; XXX Need INTEGER here because tré's FRACTION-CHARS is buggered.
  (integer (/ (? (eq tv :pal)
                 +cpu-cycles-pal+
                 +cpu-cycles-ntsc+)
              (* 8 avg-len))))

(alet (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))
  (format t "Baud rates: ~A (NTSC), ~A (PAL)~%"
          (tap-rate :ntsc !) (tap-rate :pal !)))
(format t "Done making 'Pulse'. See directory 'compiled/'.~%")

(quit)
