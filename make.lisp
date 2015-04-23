(defconstant +make-wav?+ nil)

(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))
(defvar audio_shortest_pulse #x15)
(defvar audio_longest_pulse #x25)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))

(load "game/files.lisp")
(load "game/story.lisp")

(defvar num-xlats 64)

(defun amp (x)
  (= x (* 4 x))
  (- 15
  (alet (integer (/ (* x (/ 256 audio_pulse_width)) 128))
    (? (< 15 !)
       15
       !))))

(defun amplitude-conversions ()
  (maptimes #'amp 64))

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
        "shared/start-irq-loader.asm"
        "shared/irq-loader.asm"
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
        "spinoffs/text.asm"
        "spinoffs/start.asm"))
  (make-vice-commands "obj/ohne_dich.prg.vice.txt"))

(defun make-ohne-dich-bin ()
  (apply #'assemble-files "obj/ohne_dich.bin"
      '("bender/vic-20/vic.asm"
        "bender/vic-20/via.asm"
        "spinoffs/ohne_dich.asm"
        "shared/tape_audio_player.asm"))
  (make-vice-commands "obj/ohne_dich.bin.vice.txt"))

(make-game nil)
(make-vice-commands "obj/pulse.vice.txt")
(make-game t)
(make-vice-commands "obj/game.vice.txt")
(defvar *game-start* (get-label 'main))

(make-loader-bin)
(defvar waiter_end (get-label 'waiter_end))
(defvar loaded_loader (get-label 'loaded_loader))
(defvar loader (get-label 'loader))
(defvar start_loader (get-label 'start_loader))
(defvar waiter (get-label 'waiter))
(defvar run (get-label 'run))
(make-loader-prg)

(defvar tape_audio_player 0)
(make-ohne-dich-prg)
(defvar text (get-label 'text))
(make-ohne-dich-bin)
(= tape_audio_player (get-label 'tape_audio_player))
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

(format t "Audio resolution: ~A cycles~%" (* 8 audio_pulse_width))
(format t "~A pulses per second.~%"
        (integer (/ 1000000 (* 8 (+ audio_shortest_pulse
                                    (half audio_pulse_width))))))
(format t "Amplitude conversions: ~A~%" (amplitude-conversions))

(with-output-file o "pulse.tap"
  (write-tap o
      (+ (bin2cbmtap (cddr (string-list (fetch-file "obj/loader.prg")))
                     (+ "PULSE           "
                        (fetch-file "obj/loader.bin"))
                     :start #x1001)
         (bin2pottap (string-list (fetch-file "obj/game.bin"))))))

(with-output-file o "ohne_dich.tap"
  (write-tap o
      (bin2cbmtap (cddr (string-list (fetch-file "obj/ohne_dich.prg")))
                  (+ "OHNE DICH       "
                     (fetch-file "obj/ohne_dich.bin"))
                  :start #x1001))
  (when nil
  (with (lowest  128
         highest 128)
    (format t "Getting lower/upper boundary…~%")
    (alet (fetch-file "obj/ohne_dich_4bit.wav")
      (dotimes (i (length !))
        (when (== i 128)
          (= lowest  128)
          (= highest 128))
        (let x (elt ! i)
          (?
            (< x lowest)  (= lowest (char-code x))
            (< highest x) (= highest (char-code x))))))
    (format t "Low/high: ~A, ~A~%" lowest highest)))

  (alet (fetch-file "obj/ohne_dich_4bit.wav")
    (dotimes (i (length !))
      (princ (code-char (+ audio_shortest_pulse
                           (/ (* (elt ! i) audio_pulse_width) 256)))
             o))))

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-file in in-file
    (with-output-file out out-file
      (tap2wav in out))))

(when +make-wav?+
  (make-tape-wav "pulse.tap" "pulse.tape.wav")
  (make-tape-wav "ohne_dich.tap" "ohne_dich.tape.wav"))

(quit)
