(defconstant +make-wav?+ nil)

(defvar *tape-loader-start* #x1e00)
(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(load "tape-loader/bin2pottap.lisp")
(load "spinoffs/wav2pwm.lisp")
(load "game/files.lisp")
(load "game/story.lisp")

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-file in in-file
    (with-output-file out out-file
      (tap2wav in out))))

(defun make-game (tape?)
  (apply #'assemble-files
         (? tape?
            "obj/game.bin"
            "pulse.prg")
         (+ (& tape?
               (list "game/no-loader.asm"))
            (@ [+ "bender/vic-20/" _]
               `(,@(unless tape?
                     (list "basic-loader.asm"))
                 "vic.asm"))
            (@ [+ "game/" _] +pulse-files+))))

(defun make-loader-bin ()
  (apply #'assemble-files "obj/loader.bin"
      '("primary-loader/zeropage.asm"
        "bender/vic-20/vic.asm"
        "bender/vic-20/via.asm"
        "tape-loader/loader.asm"
        "tape-loader/start.asm"
        "primary-loader/waiter.asm"))
  (make-vice-commands "obj/loader.bin.vice.txt"))

(defun make-loader-prg ()
  (apply #'assemble-files "obj/loader.prg"
      '("bender/vic-20/basic-loader.asm"
        "bender/vic-20/vic.asm"
        "primary-loader/zeropage.asm"
        "primary-loader/main.asm"))
  (make-vice-commands "obj/loader.prg.vice.txt"))

(defun make-ohne-dich-prg (name tv)
  (apply #'assemble-files (+ "obj/" name "_" tv ".prg")
      `("bender/vic-20/basic-loader.asm"
        "bender/vic-20/vic.asm"
        "spinoffs/start.asm"
        "spinoffs/tape_audio_player.asm"
        ,(+ "spinoffs/text_" name ".asm")))
  (make-vice-commands (+ "obj/" name "_" tv ".prg.vice.txt")))

(defvar *game-start* nil)
(defvar loaded_tape_loader nil)
(defvar waiter nil)
(defvar waiter_end nil)
(defvar run nil)

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

(defun make-all-games ()
;  (make-game nil)
;  (make-vice-commands "obj/pulse.vice.txt")
  (make-game t)
  (make-vice-commands "obj/game.vice.txt")
  (= *game-start* (get-label 'main))

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
           (bin2pottap (string-list (fetch-file "obj/game.bin"))))))

  (when +make-wav?+
    (make-tape-wav "compiled/pulse.tap" "compiled/pulse.tape.wav")))

(defvar *tv* nil)
(defvar ohne_dich nil)
(defvar text nil)

(defun make-ohne-dich (name tv)
  (= *tv* tv)
  (alet (downcase (symbol-name tv))
    (make-ohne-dich-prg name !)
    (make-vice-commands (+ "compiled/" name "_" ! ".vice.txt"))

    (with-output-file o (+ "compiled/" name "_" ! ".tap")
      (write-tap o
          (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/" name "_" ! ".prg"))))
                      name
                      :start #x1001))
      (? *video?*
         (with-input-file video "nipkow.dat"
           (wav2pwm o (+ "obj/" name "_downsampled_" ! ".wav") video))
         (wav2pwm o (+ "obj/" name "_downsampled_" ! ".wav"))))

    (when +make-wav?+
      (make-tape-wav (+ "compiled/" name "_" ! ".tap")
                     (+ "compiled/" name "_" ! ".tape.wav")))))

(make-all-games)
(make-ohne-dich "ohne_dich" :pal)
(make-ohne-dich "ohne_dich" :ntsc)
(make-ohne-dich "mario" :pal)
(make-ohne-dich "mario" :ntsc)
(print-pwm-info)

(format t "Done making 'Pulse'. See directory 'compiled/'.~%")

(quit)
