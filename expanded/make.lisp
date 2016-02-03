(defun make-pcm4 (out in)
  (adotimes 44
    (read-byte in))
  (with (i nil
         b 0)
    (awhile (read-word in)
            nil
      (let v (bit-xor (>> ! 12) 8)
        (? i
           (= b v)
           (write-byte (byte (+ b (<< v 4))) out)))
      (= i (toggle i)))))

(defun make-pcm2 (out in)
  (adotimes 44
    (read-byte in))
  (with (i 0
         b 0)
    (awhile (read-word in)
            nil
      (with (v (bit-xor (>> ! 14) 2))
        (= b (bit-or b v)))
        (when (== i 3)
          (write-byte (byte b) out)
          (= b 0)
          (= i -1))
        (= b (<< b 2))
        (++! i))))

(defun convert-to-pcm4 (in-name out-name)
  (format t "Converting `~A' to 4–bit audio `~A'…~%" in-name out-name)
  (with-input-file in in-name
    (with-output-file out out-name
      (make-pcm4 out in))))

(defun convert-to-pcm2 (in-name out-name)
  (format t "Converting `~A' to 2–bit audio `~A'…~%" in-name out-name)
  (with-input-file in in-name
    (with-output-file out out-name
      (make-pcm2 out in))))

(defun make-ram-audio (name file gain bass)
  (nipkow-make-wav name file)
  (nipkow-make-filtered-wav name gain bass :ram *ram-audio-rate*)
  (nipkow-make-conversion name :ram *ram-audio-rate*)
  (convert-to-pcm4 (+ "obj/" name ".downsampled.ram.wav")
                   (+ "obj/" name ".pcm4")))

(defun make-ram-audio2 (name file gain bass)
  (nipkow-make-wav name file)
  (nipkow-make-filtered-wav name gain bass :ram *ram-audio-rate2*)
  (nipkow-make-conversion name :ram *ram-audio-rate2*)
  (convert-to-pcm2 (+ "obj/" name ".downsampled.ram.wav")
                   (+ "obj/" name ".pcm2")))

(defvar *have-ram-audio-player?* nil)
(defvar *have-ram-audio-player2?* nil)
(defvar *tape-loader-start-returning?* nil)

(defun make-8k (name imported-labels)
  (with-temporaries (*imported-labels* imported-labels
                     *have-ram-audio-player?* t
                     *have-ram-audio-player2?* nil)
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/" name "." ! ".prg")
            '("expanded/init-8k.asm"
              "expanded/patch-8k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/hiscore-table.asm"
              "expanded/print.asm"
              "expanded/gfx-title.asm"
              "expanded/ram-audio-player.asm"
              "expanded/ram-audio-player2.asm")
            (+ "obj/" name "." ! ".prg.vice.txt"))
      (exomize (+ "obj/" name "." ! ".prg")
               (+ "obj/" name ".crunched." ! ".prg")
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
