(defun make-pwm (out in)
  (adotimes 44
    (read-byte in))
  (with (i nil
         b 0)
    (awhile (read-word in)
            nil
      (let v (integer (+ 8 (>> ! 12)))
        (? i
           (= b v)
           (write-byte (byte (+ b (<< v 4))) out)))
      (= i (toggle i)))))

(let v 0
  (defun dither-sample (x)
    (= v (+ v x)))
  (defun set-dither-error (x)
;    (print x)
    (= v (- v x))))

(defun word-int (x)
  (? (< #x7fff x)
     (- x #x10000)
     x))

(defun make-pwm2 (out in)
  (adotimes 44
    (read-byte in))
  (with (i 0
         b 0)
    (awhile (read-word in)
            nil
;            (print '----------)
;      (print (word-int !))
      (with (v (bit-xor (>> (word (dither-sample (word-int !))) 14) 2))
;            (print v)
        (set-dither-error (print (- (<< v 14) #x8000)))
        (= b (bit-or b v)))
      (when (== i 3)
        (write-byte (byte b) out)
        (= b 0)
        (= i -1))
      (= b (<< b 2))
      (++! i))))

(defun convert-to-pwm (in-name out-name)
  (with-input-file in in-name
    (with-output-file out out-name
      (make-pwm out in))))

(defun convert-to-pwm2 (in-name out-name)
  (with-input-file in in-name
    (with-output-file out out-name
      (make-pwm2 out in))))

(defun make-ram-audio (name file gain bass)
  (make-wav name file)
  (make-filtered-wav name gain bass :ram *ram-audio-rate*)
  (make-conversion name :ram *ram-audio-rate*)
  (convert-to-pwm "obj/get_ready.downsampled.ram.wav"
                  "obj/get_ready.pwm"))

(defun make-ram-audio2 (name file gain bass)
  (make-wav name file)
  (make-filtered-wav name gain bass :ram *ram-audio-rate*)
  (make-conversion name :ram *ram-audio-rate*)
  (convert-to-pwm2 "obj/intermediate.downsampled.ram.wav"
                   "obj/intermediate.pwm"))

(defvar *have-ram-audio-player?* nil)
(defvar *have-ram-audio-player2?* nil)
(defvar *tape-loader-start-returning?* nil)

(defun make-8k (imported-labels)
  (with-temporaries (*imported-labels* imported-labels
                     *have-ram-audio-player?* t
                     *have-ram-audio-player2?* t)
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/8k." ! ".prg")
            '("expanded/init-8k.asm"
              "expanded/patch-8k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/print.asm"
              "expanded/gfx-title.asm"
              "expanded/ram-audio-player.asm"
              "expanded/ram-audio-player2.asm")
            (+ "obj/8k." ! ".prg.vice.txt"))
      (exomize (+ "obj/8k." ! ".prg")
               (+ "obj/8k.crunched." ! ".prg")
               "2002" "52"))))

(defun make-3k (imported-labels)
  (with-temporary *imported-labels* imported-labels
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/patch-3k." ! ".bin")
            '("expanded/patch-3k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/print.asm"
              "expanded/gfx-title.asm")
            (+ "obj/patch-3k." ! ".bin.vice.txt"))
      (make (+ "obj/3k." ! ".prg")
            '("primary-loader/models.asm"
              "primary-loader/zeropage.asm"
              "expanded/init-3k.asm"
              "secondary-loader/start.asm")
            (+ "obj/3k." ! ".prg.vice.txt"))
      (exomize (+ "obj/3k." ! ".prg")
               (+ "obj/3k.crunched." ! ".prg")
               "1002" "20"))))
