;(cl:proclaim '(optimize (speed 0) (space 0) (safety 3) (debug 3)))

(defun wav-to-4bit (from to)
  (format t "Converting '~A' to 4-bit '~A'…~%" from to)
  (with-input-file i from
    (with-output-file o to
      (awhile (read-byte i)
              nil
        (write-byte (>> (bit-and (+ 128 !) 255) 4) o)))))

(let f 0
  (defun init-delta-compress ()
    (= f 0))
  (defun delta-compress (o x)
    (write-byte (bit-and (byte (- x f)) 15) o)
    (= f x)))

(defun delta-compress-file (from to)
  (init-delta-compress)
  (with-input-file i from
    (with-output-file o to
      (awhile (read-byte i)
              nil
        (delta-compress o !)))))

(let f 0
  (defun init-ldelta-compress ()
    (= f 0))
  (defun ldelta-compress (o x)
    (write (?
             (< x f) (progn (++! f) 1)
             (> x f) (progn (--! f) 255)
             0)
           o)
    (= f x)))

(defun ldelta-compress-file (from to)
  (init-ldelta-compress)
  (with-input-file i from
    (with-output-file o to
      (awhile (read-byte i)
              nil
        (ldelta-compress o !)))))

(let f 0
  (defun init-delta-uncompress ()
    (= f 0))
  (defun delta-uncompress (o x)
    (write-byte (= f (byte (+ x f))) o)))

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
          (= (aref probs i) (list i (aref ! i))))
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
 
(defun init-audio-model ()
  (with (a (make-array 16)
         s (make-array 17))
    (= (aref s 0) 0)
    (dotimes (i 16 (values a s))
      (= (aref a i) 1)
      (= (aref s (++ i)) (* (++ i) 1)))))

(defun update-audio-model (a s x v)
  (unless (zero? (+ v (aref a x)))
    (= (aref a x) (+ v (aref a x)))
    (while (not (== x 17))
           nil
      (= (aref s x) (+ v (aref s x)))
      (++! x))))

(defun arith-encode (num-bits i o)
  (with (top (<< 1 num-bits)
         ma  (-- top)
         ha  (half top)
         hap (++ ha)
         ham (-- ha)
         uq  (* 3 (/ top 4))
         lq  (/ top 4)
         hi  ma
         lo  0
         (a s)  (init-audio-model)
         win    (aprog1 (make-queue)
                  (dotimes (i 240)
                    (enqueue ! 1)))
         total  256
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
                  (= lo (bit-and (<< lo 1) ham))))
    (format t "~FTop: ~A~%" top)
    (awhile (read-byte i)
            nil
      (with (range (++ (- hi lo))
             total (aref s 16))
;        (print a)
;        (format t "in: ~A, ~A, range: ~A, hi: ~A, lo: ~A p: ~A, d: ~A, diff: ~A~%" ! s range hi lo (cadr (aref probs s)) (aref denoms s) (integer (/ (* range (aref denoms s)) total)))
        (| (<= range top)
           (error "Range overflow ~A." range))
        (= hi (integer (+ lo (/ (* range (aref s (++ !))) total))))
        (= lo (integer (+ lo (/ (* range (aref s !)) total))))
        (update-audio-model a s ! 1)
        (update-audio-model a s (queue-pop win) -1)
        (enqueue win !)
;        (format t "*Hi: ~A, lo: ~A~%" hi lo)
        (loop
;          (format t "Hi: ~A, lo: ~A~%" hi lo)
          (?
            (< hi ha)       (out0)
            (>= lo  ha)     (out1)
            (& (< hi  uq)
               (>= lo  lq)) (outx)
            (return)))))
    (adotimes num-bits (out0))))

(defun compress (num-bits in out)
  (format t "Arithmetic encoding of '~A' to '~A'…~%" in out)
  (with-input-file i in
    (with-output-file o out
      (arith-encode num-bits i (make-bit-stream :out o)))))

(defun arith-decode (probs num-bits num-bytes i o)
  (with (top    (<< 1 num-bits)
         ma     (-- top)
         ha     (half top)
         hap    (++ ha)
         ham    (-- ha)
         uq     (* 3 (/ top 4))
         lq     (/ top 4)
         hi     ma
         lo     0
         denoms (make-denoms probs)
         total  (apply #'+ (@ #'cadr (array-list probs)))
         value   0)
    (adotimes 8
      (= value (+ (<< value 1) (read-byte i))))
    (while (not (zero? (--! num-bytes)))
           nil
      (with (range  (- hi lo -1)
             diff   (- value lo -1)
             cnt    (/ (* total diff) range)
             s      (position-if [< cnt _] denoms)
             c      (car (elt probs s)))
        (write-byte c o)
;        (format t "~Lin: ~A, ~A, range: ~A, hi: ~A, lo: ~A p: ~A, d: ~A, diff: ~A, cnt: ~A~%" c s range hi lo (cadr (aref probs s)) (aref denoms s) diff (integer cnt))
        (= hi (integer (+ lo (/ (* range (aref denoms (++ s))) total) -1)))
        (= lo (integer (+ lo (/ (* range (aref denoms s)) total))))
        (loop
          (?
            (| (>= lo ha)
               (< hi ha))
              (progn
                (= lo (bit-and (<< lo 1) ma))
                (= hi (bit-and (bit-or (<< hi 1) 1) ma))
                (= value (+ value (read-byte i))))
            (& (>= lo lq)
               (< hi uq))
              (progn
                (= lo (bit-and (<< lo 1) ham))
                (= hi (bit-and (<< hi 1) ma))
                (= hi (bit-or hi hap))
                (= value (+ value (read-byte i))))
            (return)))))))


(defun uncompress (probs num-bits num-bytes in out)
  (format t "Arithmetic decoding of '~A' to '~A'…~%" in out)
  (with-input-file i in
    (with-output-file o out
      (arith-decode probs num-bits num-bytes (make-bit-stream :in i) o))))

;(wav-to-4bit "obj/theme2_downsampled_pal.wav" "4bit.bin")
;(delta-compress-file "4bit.bin" "delta.bin")
(with-output-file o "numbers.bin" (princ (list-string '(5 6 7 8 9 0 1 2 3 4)) o))
(compress 8 "4bit.bin" "hiscore-theme.bin")
(quit)