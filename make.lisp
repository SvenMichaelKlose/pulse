(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(load "files.lisp")
(load "story.lisp")

(defun assemble-game (tape?)
  (apply #'assemble-files
         (? tape?
            "game.bin"
            "pulse.prg")
         (+ (& tape?
               (list "game/no-loader.asm"))
            (@ [+ "bender/vic-20/" _]
               `(,@(unless tape?
                     (list "basic-loader.asm"))
                 "vic.asm"))
            (@ [+ "game/" _] +pulse-files+))))

(assemble-game nil)
(make-vice-commands "pulse.vice.txt")
(assemble-game t)
(make-vice-commands "game.vice.txt")
(defvar *game-start* (get-label 'main))

(apply #'assemble-files "loader.prg"
      '("primary-loader/zeropage.asm"
        "bender/vic-20/vic.asm"
        "bender/vic-20/basic-loader.asm"
        "primary-loader/main.asm"
        "shared/start-irq-loader.asm"
        "shared/irq-loader.asm"
        "primary-loader/waiter.asm"))
(make-vice-commands "loader.vice.txt")


(defun bin2pottap (x)
  (with-queue q
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x04))
    (enqueue q (code-char #x30))
    (dolist (i x (list-string (queue-list q)))
      (when (< i 0)
        (= i (+ 256 i)))
      (dotimes (j 8)
        (enqueue q (code-char (? (zero? (bit-and i 1))
                                 *pulse-short*
                                 *pulse-long*)))
        (= i (>> i 1))))))

(with-output-file o "pulse.tap"
  (write-tap o
      (+ (bin2cbmtap (cddr (string-list (fetch-file "loader.prg")))
                     "PULSE"
                     :start #x1001)
         (bin2pottap (string-list (fetch-file "game.bin"))))))

(with-input-file i "pulse.tap"
  (with-output-file o "pulse.wav"
    (tap2wav i o)))
(quit)
