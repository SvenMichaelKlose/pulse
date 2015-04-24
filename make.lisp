(defconstant +make-wav?+ nil)

(defvar *tape-loader-start* #x1e00)
(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(load "spinoffs/wav2pwm.lisp")
(load "game/files.lisp")
(load "game/story.lisp")

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
        "tape-loader/start.asm"
        "tape-loader/loader.asm"
        "primary-loader/waiter.asm")))

(defun make-loader-prg ()
  (apply #'assemble-files "obj/loader.prg"
      '("bender/vic-20/basic-loader.asm"
        "bender/vic-20/vic.asm"
        "primary-loader/zeropage.asm"
        "primary-loader/main.asm"))
  (make-vice-commands "obj/loader.prg.vice.txt"))

(defun make-ohne-dich-prg ()
  (apply #'assemble-files "obj/ohne_dich.prg"
      '("bender/vic-20/basic-loader.asm"
        "bender/vic-20/vic.asm"
        "spinoffs/start.asm"
        "spinoffs/text.asm"))
  (make-vice-commands "obj/ohne_dich.prg.vice.txt"))

(defun make-ohne-dich-bin ()
  (apply #'assemble-files "obj/ohne_dich.bin"
      '("bender/vic-20/vic.asm"
        "bender/vic-20/via.asm"
        "spinoffs/ohne_dich.asm"
        "spinoffs/tape_audio_player.asm"))
  (make-vice-commands "obj/ohne_dich.bin.vice.txt"))

(make-game nil)
(make-vice-commands "obj/pulse.vice.txt")
(make-game t)
(make-vice-commands "obj/game.vice.txt")
(defvar *game-start* (get-label 'main))

(make-loader-bin)
(defvar loaded_tape_loader (get-label 'loaded_tape_loader))
(defvar waiter (get-label 'waiter))
(defvar waiter_end (get-label 'waiter_end))
(defvar run (get-label 'run))
(make-loader-prg)

(defvar ohne_dich 0)
(make-ohne-dich-prg)
(defvar text (get-label 'text))
(make-ohne-dich-bin)
(= ohne_dich (get-label 'ohne_dich))
(make-ohne-dich-prg)

(defun bin2pottap-byte (q i)
  (when (< i 0)
    (= i (+ 256 i)))
   (dotimes (j 8)
     (enqueue q (code-char (? (zero? (bit-and i 1))
                              *pulse-short*
                              *pulse-long*)))
     (= i (>> i 1))))

(defun bin2pottap (x)
  (with-queue q
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x04))
    (enqueue q (code-char #x30))
    (dolist (i x (list-string (queue-list q)))
      (bin2pottap-byte q i))))

(with-output-file o "compiled/pulse.tap"
  (write-tap o
      (+ (bin2cbmtap (cddr (string-list (fetch-file "obj/loader.prg")))
                     (+ "PULSE           "
                        (fetch-file "obj/loader.bin"))
                     :start #x1001)
         (bin2pottap (string-list (fetch-file "obj/game.bin"))))))

(with-output-file o "compiled/ohne_dich.tap"
  (write-tap o
      (bin2cbmtap (cddr (string-list (fetch-file "obj/ohne_dich.prg")))
                  (+ "OHNE DICH       "
                     (fetch-file "obj/ohne_dich.bin"))
                  :start #x1001))
  (wav2pwm o "obj/ohne_dich_downsampled.wav"))

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-file in in-file
    (with-output-file out out-file
      (tap2wav in out))))

(when +make-wav?+
  (make-tape-wav "compiled/pulse.tap" "compiled/pulse.tape.wav")
  (make-tape-wav "compiled/ohne_dich.tap" "compiled/ohne_dich.tape.wav"))

(print-pwm-info)

(format t "Done making 'Pulse'. See directory 'compiled/'.~%")

(quit)
