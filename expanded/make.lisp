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

(defun convert-to-pwm (in-name out-name)
  (with-input-file in in-name
    (with-output-file out out-name
      (make-pwm out in))))

(defun make-ram-audio (name file gain bass)
  (make-wav name file gain bass :ram *ram-audio-rate*)
  (make-conversion name :ram *ram-audio-rate*)
  (convert-to-pwm "obj/get_ready.downsampled.ram.wav"
                  "obj/get_ready.pwm"))

(defvar *have-ram-audio-player?* nil)
(defvar *tape-loader-start-returning?* nil)

(defun make-8k (imported-labels)
  (with-temporaries(*imported-labels* imported-labels
                    *have-ram-audio-player?* t)
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/8k." ! ".prg")
            '("expanded/init-8k.asm"
              "expanded/patch-8k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/print.asm"
              "expanded/gfx-title.asm"
              "expanded/ram-audio-player.asm")
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
              "radio/zeropage.asm"
              "expanded/init-3k.asm"
              "secondary-loader/start.asm")
            (+ "obj/3k." ! ".prg.vice.txt"))
      (exomize (+ "obj/3k." ! ".prg")
               (+ "obj/3k.crunched." ! ".prg")
               "1002" "20"))))
