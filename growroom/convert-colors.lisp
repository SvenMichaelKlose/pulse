(defun convert-splash-bit (x)
  (?
    (== x 0)  1
    (== x 1)  0
    x))

(defun convert-splash-byte-mc (out x)
  (let v 0
    (dotimes (i 4 (write-byte v out))
      (let s (* 2 i)
        (= v (+ v (<< (convert-splash-bit (>> (bit-and x (<< 3 s)) s)) s)))))))

(defun convert-splash-byte-sc (out x)
  (let v 0
    (dotimes (i 8 (write-byte v out))
      (= v (+ v (<< (convert-splash-bit (>> (bit-and x (<< 1 i)) i)) i))))))

(defun convert-splash-colors (out in screen colors)
  (dotimes (i 160)
    (let c (char-code (elt colors (position-if [== _ i] screen)))
      (dotimes (j 8)
        (? (zero? (bit-and c 8))
           (convert-splash-byte-sc out (read-byte in))
           (convert-splash-byte-mc out (read-byte in)))))))

(with-input-file in "obj/splash.chars.bin"
  (with-output-file out "obj/splash.chars.negated.bin"
    (convert-splash-colors out in
                           (fetch-file "obj/splash.screen.bin")
                           (fetch-file "obj/splash.colors.bin"))))
