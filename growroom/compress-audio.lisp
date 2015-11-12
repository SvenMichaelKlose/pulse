(defun wav-to-4bit (from to)
  (format t "Converting '~A' to 4-bit '~A'…~%" from to)
  (with-input-file i from
    (with-output-file o to
      (awhile (read-byte i)
              nil
        (princ (code-char (>> (bit-and (+ 128 !) 255) 4)) o)))))

(let f 0
  (defun init-delta-compress ()
    (= f 0))
  (defun delta-compress (o x)
    (princ (code-char (byte (- x f))) o)
    (= f x)))

(defun delta-compress-file (from to)
  (init-delta-compress)
  (with-input-file i from
    (with-output-file o to
      (awhile (read-byte i)
              nil
        (delta-compress o !)))))

(let f 0
  (defun init-delta-uncompress ()
    (= f 0))
  (defun delta-uncompress (o x)
    (princ (code-char (= f (byte (+ x f)))) o)))

(defun delta-uncompress-file (from to)
  (init-delta-uncompress)
  (with-input-file i from
    (with-output-file o to
      (awhile (read-byte i)
              nil
        (delta-uncompress o !)))))

(defun test-delta-compression (in)
  (format t "Delta compression with '~A'…~%" in)
  (delta-compress-file "4bit.bin" "delta.bin")
  (format t "Delta uncompression…~%")
  (delta-uncompress-file "delta.bin" "undelta.bin")
  (unless (equal (fetch-file "4bit.bin") (fetch-file "undelta.bin"))
    (error "Failed.")))

(defun get-probabilities (x num-bits)
  (let top (<< 1 num-bits)
    (alet (make-array 256)
      (dotimes (i 256)
        (= (aref ! i) 0))
      (dotimes (i (length x))
        (++! (aref ! (char-code (aref x i)))))
      (with (total (apply #'+ (array-list !))
             probs (make-array 256))
        (dotimes (i 256)
          (= (aref probs i) (list i (let v (integer (/ (* top (aref ! i)) total))
                                      (? (& (zero? v)
                                            (not (zero? (aref ! i))))
                                         1
                                         v)))))
        (alet (remove-if [zero? ._.] probs)
          (format t "Total is ~A with ~A symbols.~%"
                  (apply #'+ (@ #'cadr (array-list !)))
                  (length !))
          (sort ! :test #'((a b) (>= .a. .b.))))))))

(defun make-denoms (probs)
  (aprog1 (make-array (++ (length probs)))
    (dotimes (i (length probs))
      (= (aref ! (++ i)) (cadr (aref probs i))))
    (dotimes (i (length probs))
      (= (aref ! (++ i)) (+ (aref ! (++ i)) (aref ! i))))))
 
(defun arith-encode (probs num-bits i o)
  (with (top (<< 1 num-bits)
         ma  (-- top)
         ha  (half top)
         hap (++ ha)
         ham (-- ha)
         uq  (* 3 (/ top 4))
         lq  (/ top 4)
         hi  (-- top)
         lo #x00
         denoms (make-denoms probs)
         pending-bits 0
         out0 #'(()
                  (princ 0 o)
                  (= hi (bit-and (bit-or (<< hi 1) 1) ma))
                  (= lo (bit-and (<< lo 1) ma)))
         out1 #'(()
                  (princ 1 o)
                  (= hi (bit-and (bit-or (<< hi 1) 1) ma))
                  (= lo (bit-and (<< lo 1) ma)))
         outx #'(()
                  (++! pending-bits)
                  (= hi (bit-and (bit-or (<< hi 1) hap) ma))
                  (= lo (bit-and (<< lo 1) ham)))
         indexes (aprog1 (make-array 256)
                   (dotimes (i (length probs))
                     (= (aref ! i) (position-if [== i _.] probs)))))
    (format t "~FTop: ~A~%" top)
    (print denoms)
    (awhile (read-byte i)
            nil
;      (print !)
      (with (range (++ (- hi lo))
             i     (aref indexes !))
;        (format t "in: ~A, range: ~A, hi: ~A, lo: ~A p: ~A, d: ~A~%" i range hi lo (cadr (aref probs (++ i))) (aref denoms i))
        (= hi (integer (+ lo (>> (* range (aref denoms (++ i))) 8))))
        (= lo (integer (+ lo (>> (* range (aref denoms i)) 8))))
;        (format t "*Hi: ~A, lo: ~A~%" hi lo)
        (loop
;          (format t "Hi: ~A, lo: ~A~%" hi lo)
          (?
            (< hi ha)       (out0)
            (>= lo  ha)     (out1)
            (& (< hi  uq)
               (>= lo  lq)) (outx)
            (return)))))))

(defun compress (num-bits in out)
  (format t "Arithmetic encoding of '~A' to '~A'…~%" in out)
  (alet (get-probabilities (string-array (fetch-file in)) num-bits)
    (print !)
    (with-input-file i in
      (with-output-file o out
        (arith-encode ! num-bits i (make-bit-stream :out o))))))

(defun arith-decode (probs i o)
  (with (hi #xff
         lo #x00
         denoms (make-denoms probs)
         pending-bits 0
         bits   1
         in-byte 0
         value   0
         get-bit #'(()
                      (prog1 (bit-and in-byte 1)
                        (= bits (<< bits 1))
                        (when (== bits 256)
                          (= bits 1)
                          (= in-byte (read-byte i))))))
    (adotimes 8
      (= value (+ (<< value 1) (get-bit))))
    (loop
      (with (range  (- hi lo -1)
             cnt    (- value lo)
             s      (-- (position-if [< cnt _] denoms)))
        (princ (code-char (car (elt probs s))) o)
        (= hi (integer (+ lo (>> (* range (aref denoms (++ s))) 8) -1)))
        (= lo (integer (+ lo (>> (* range (aref denoms s)) 8))))
        (loop
          (?
            (& (>= lo #x80)
               (< hi #x80))
              (progn
                (= lo (bit-and (<< lo 1) #xff))
                (= hi (bit-or (<< hi 1) 1))
                (= in-byte (+ in-byte (get-bit))))
            (& (>= lo #x40)
               (< hi #xc0))
              (progn
                (= lo (bit-and (<< lo 1) #x7f))
                (= hi (<< hi 1))
                (= hi (bit-or hi #x81))
                (= in-byte (+ in-byte (get-bit))))
            (return)))))))


;(wav-to-4bit "obj/theme2_downsampled_pal.wav" "4bit.bin")
;(test-delta-compression "4bit.bin")

;(sb-ext:run-program "/bin/cp" (list "delta.bin" "sdelta.bin"))
;(test-delta-compression "sdelta.bin")

(compress 16 "pop.prg" "compressed.bin")
(quit)
