;(cl:proclaim '(optimize (speed 0) (space 0) (safety 3) (debug 3)))

(defconstant +sample-bits+ 4)
(defconstant +count-bits+ 8)
(defconstant +window-bits+ (+ 1 +sample-bits+ +count-bits+))

(defun wav-to-4bit (from to)
  (format t "Converting '~A' to 4-bit '~A'…~%" from to)
  (with-input-file i from
    (with-output-file o to
      (adotimes 44 (read-byte i))
      (awhile (read-word i)
              nil
        (write-byte (bit-xor (>> ! 12) 8) o)))))

(defun init-audio-model ()
  (values (list-array (maptimes [identity 16] 16))
          (list-array (maptimes [* _ 16] 17))))

(defun update-audio-model (a s x v)
  (unless (zero? (+ v (aref a x)))
    (= (aref a x) (+ v (aref a x)))
    (++! x)
    (while (not (== x 17))
           nil
      (= (aref s x) (+ v (aref s x)))
      (++! x))))

(defun make-window ()
  (aprog1 (make-queue)
    (dotimes (i 240)
      (enqueue ! (mod i 16)))))

(defun adapt-sample (hi lo range a s win sym)
  (with (h  (+ lo (integer (/ (integer (* range (aref s (++ sym)))) 256)) -1)
         l  (+ lo (integer (/ (integer (* range (aref s sym))) 256))))
    (update-audio-model a s (queue-pop win) -1)
    (update-audio-model a s sym 1)
    (enqueue win sym)
    (values h l)))

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
         win    (make-window)
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
    (awhile (read-byte i)
            nil
      (with (range (++ (- hi lo)))
        (print a)
        (| (<= range top)
           (error "Range overflow ~A." range))
        (with ((h l) (adapt-sample hi lo range a s win !))
          (= hi h
             lo l))
        (loop
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

(defun arith-decode (num-bits num-bytes i o)
  (with (top    (<< 1 num-bits)
         ma     (-- top)
         ha     (half top)
         hap    (++ ha)
         ham    (-- ha)
         uq     (* 3 (/ top 4))
         lq     (/ top 4)
         hi     ma
         lo     0
         (a s)  (init-audio-model)
         win    (make-window)
         total  256
         value   0)
    (adotimes 8
      (= value (+ (<< value 1) (read-byte i))))
    (while (not (zero? (--! num-bytes)))
           nil
      (with (range  (- hi lo -1)
             diff   (- value lo -1)
             cnt    (integer (/ (integer (* total diff) range)))
             sym    (position-if [< cnt _] s))
        (write-byte sym o)
        (with ((h l) (adapt-sample hi lo range a s win sym))
          (= hi h
             lo l))
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


(defun uncompress (num-bits num-bytes in out)
  (format t "Arithmetic decoding of '~A' to '~A'…~%" in out)
  (with-input-file i in
    (with-output-file o out
      (arith-decode num-bits num-bytes (make-bit-stream :in i) o))))

(defun compress-hiscore-theme ()
  (wav-to-4bit "obj/theme-hiscore.downsampled.ram.wav" "obj/hiscore.4bit.bin")
  (compress +window-bits+ "obj/hiscore.4bit.bin" "obj/hiscore-theme.bin"))

(compress-hiscore-theme)
(quit)
