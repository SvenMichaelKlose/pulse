(defvar b 0)
(defvar bits-left 0)

(defun store-bit (o x)
  (when (zero? bits-left)
    (= bits-left 8)
    (= b 0))
  (!-- bits-left)
  (= b (bit-or b (bit-and x 1))))

(defun byte (x)
  (bit-and #xff
    (?
      (< x 0)  (+ 256 x)
      x)))

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

(defun get-probabilities (x)
  (alet (make-array 256)
    (dotimes (i 256)
      (= (aref ! i) 0))
    (dotimes (i (length x))
      (++! (aref ! (char-code (aref x i)))))
    (with (total (apply #'+ (array-list !))
           probs (make-array 256))
      (dotimes (i 256)
        (= (aref probs i) (list i (let v (integer (/ (* 256 (aref ! i)) total))
                                    (? (& (zero? v)
                                          (not (zero? (aref ! i))))
                                       1
                                       v)))))
      (alet (remove-if [zero? ._.] probs)
        (format t "Total is ~A with ~A symbols.~%"
                (apply #'+ (@ #'cadr (array-list !)))
                (length !))
        (print (sort ! :test #'((a b) (>= .a. .b.))))))))

(defun make-denoms (probs)
  (aprog1 (make-array (++ (length probs)))
    (dotimes (i (length probs))
      (= (aref ! (++ i)) (cadr (aref probs i))))
    (dotimes (i (length probs))
      (= (aref ! (++ i)) (+ (aref ! (++ i)) (aref ! i))))))
 
(defun arith-encode (probs i o)
  (with (hi #xff
         lo #x00
         denoms (make-denoms probs)
         pending-bits 0
         bits   1
         out-byte 0
         outbit [(= bits (<< bits 1))
                 (when (== bits 256)
                   (princ (code-char out-byte) o)
                   (= out-byte 0)
                   (= bits 1))
                 (when _
                   (= out-byte (bit-or out-byte bits)))]
         out0 #'(()
                  (outbit nil)
                  (= hi (bit-or (<< hi 1) 1))
                  (= lo (<< lo 1)))
         out1 #'(()
                  (outbit t)
                  (= hi (bit-or (<< hi 1) 1))
                  (= lo (<< lo 1)))
         outx #'(()
                  (++! pending-bits)
                  (= hi (<< hi 1))
                  (= hi (bit-or hi #x81))
                  (= lo (<< lo 1))
                  (= lo (bit-and lo #x7f)))
         indexes (aprog1 (make-array 256)
                   (dotimes (i (length probs))
                     (= (aref ! i) (position-if [== i _.] probs)))))
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
            (< hi #x80)      (out0)
            (>= lo  #x80)     (out1)
            (& (< hi  #xc0)
               (>= lo  #x40)) (outx)
            (return))
          (= hi (bit-and #xff hi))
          (= lo (bit-and #xff lo)))))))

(defun compress (in out)
  (format t "Arithmetic encoding of '~A' to '~A'…~%" in out)
  (alet (get-probabilities (string-array (fetch-file in)))
    (with-input-file i in
      (with-output-file o out
        (arith-encode ! i o)))))

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
                (= lo (<< lo 1))
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


(wav-to-4bit "obj/theme2_downsampled_pal.wav" "4bit.bin")
;(test-delta-compression "4bit.bin")

;(sb-ext:run-program "/bin/cp" (list "delta.bin" "sdelta.bin"))
;(test-delta-compression "sdelta.bin")

(compress "4bit.bin" "compressed.bin")
(quit)
