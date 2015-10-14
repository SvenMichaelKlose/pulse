(= *model* :vic-20)

(defvar *virtual?* nil)
(defvar *coinop?* nil)
(defvar *video?* nil)
(defvar *nipkow-fx-border?* t)
(defvar *nipkow-disable-interrupts?* nil)
(defvar *nipkow-joystick-stop?* nil)
(defvar *nipkow-return-address* #x100d)

(defvar *bandwidth* 16)
(defvar *tape-loader-start* #x0200)
(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(defvar audio_shortest_pulse #x18)
(defvar audio_longest_pulse #x28)
(defvar frame_sync_width #x08)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar audio_average_pulse (+ audio_shortest_pulse (half audio_pulse_width)))

(load "tape-loader/bin2pottap.lisp")
(load "nipkow/src/wav2pwm.lisp")
(load "game/files.lisp")
(load "game/story.lisp")
;(load "splash.lisp")

(defun check-zeropage-size ()
  (when (< #x100 *pc*)
    (error "Zero page overflow by ~A bytes." (- *pc* #x100))))

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

(make-audio "theme" "media/theme-boray.mp3" "4" "-72")

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-output-file in   in-file
                          out  out-file
    (tap2wav in out)))

(defun make (to files cmds)
  (apply #'assemble-files to files)
  (make-vice-commands cmds "break .stop"))

(defun make-game (version file cmds)
  (make file
        (@ [+ "game/" _] (pulse-files version))
        cmds))

(defun make-loader-bin ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/loader." ! ".bin")
          '("primary-loader/zeropage.asm"
            "bender/vic-20/vic.asm"
            "bender/vic-20/via.asm")
          (+ "obj/loader." ! ".bin.vice.txt"))))

(defun make-loader-prg ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/loader." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/zeropage.asm"
            "bender/vic-20/basic-loader.asm"
            "primary-loader/main.asm"
            "tape-loader/loader.asm"
            "tape-loader/start.asm"
            "nipkow/src/audio-player.asm"
            "primary-loader/waiter.asm")
          (+ "obj/loader." ! ".prg.vice.txt"))))

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

(defvar *tv* nil)

(defun make-all-games (tv-standard)
  (with-temporary *tv* tv-standard
    (let tv (downcase (symbol-name *tv*))
      (make-game :tap
                 (+ "obj/game." tv ".prg")
                 (+ "obj/game." tv ".vice.txt"))
      (format t "Compressing game with exomizer...~%")
      (sb-ext:run-program "/usr/local/bin/exomizer" `("sfx" "sys"
                                                      "-t" "20"
                                                      "-o" ,(+ "obj/game.crunched." tv ".prg")
                                                      ,(+ "obj/game." tv ".prg")))
      (make-loader-prg)
      (with-output-file o (+ "compiled/pulse." tv ".tap")
        (write-tap o
            (+ (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/loader." tv ".prg"))))
                           (+ "PULSE (" (upcase tv) ")")
                           :start #x1001)
               (bin2pottap (string-list (fetch-file (+ "obj/game.crunched." tv ".prg"))))))
        (adotimes 256 (princ (code-char #x20) o))
        (wav2pwm o (+ "obj/theme_downsampled_" tv ".wav")))
      (sb-ext:run-program "/usr/bin/zip"
                          (list (+ "compiled/pulse." tv ".tap.zip")
                                (+ "compiled/pulse." tv ".tap"))))))

(make-game :prg "pulse.prg" "obj/pulse.vice.txt")
(make-all-games :pal)
(make-all-games :ntsc)
(with-temporary *virtual?* t
  (make-game :virtual "compiled/virtual.bin" "obj/virtual.vice.txt"))
(with-temporary *virtual?* t
  (with-temporary *coinop?* t
    (make-game :virtual "compiled/coinop.bin" "obj/coinop.vice.txt")))

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
