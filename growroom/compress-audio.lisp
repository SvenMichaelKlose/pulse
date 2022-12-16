
;(cl:proclaim '(cl:optimize (cl:speed 0) (cl:space 0) (cl:safety 3) (cl:debug 3)))
(cl:proclaim '(cl:optimize (cl:speed 3) (cl:space 0) (cl:safety 0) (cl:debug 0)))

(defconstant +sample-bits+ 4)
(defconstant +count-bits+ 8)
(defconstant +window-bits+ 16);(+ 1 +sample-bits+ +count-bits+))

(defun wav-to-4bit (from to)
  (format t "Converting '~A' to 4-bit '~A'…~%" from to)
  (with-io i from
           o to
    (adotimes 44 (read-byte i))
    (awhile (read-word i)
            nil
      (write-byte (bit-xor (>> ! 12) 8) o))))

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

(defun adapt-sample (dump hi lo range a s win sym)
;  (format dump "~A h: ~A, l: ~A~%"
;          (+ lo (integer (/ (* range (aref s sym)) 256)))
;          (print-hexbyte (aref s (++ sym)) nil)
;          (print-hexbyte (aref s sym) nil))
  (with (h  (-- (+ lo (integer (/ (* range (aref s (++ sym))) 256))))
         l  (+ lo (integer (/ (* range (aref s sym)) 256))))
;    (format dump "~A~%" l)
    (update-audio-model a s (queue-pop win) -1)
    (update-audio-model a s sym 1)
    (enqueue win sym)
    (values h l)))

(defun arith-encode (num-bits i o)
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
         pending-bits 0
         out-plus-pending
              [(write-byte _ o)
               (adotimes pending-bits
                 (write-byte (bit-xor _ 1) o))
               (= pending-bits 0)]
         out0 #'(()
                  (out-plus-pending 0)
                  (= hi (bit-and (bit-or (<< hi 1) 1) ma))
                  (= lo (bit-and (<< lo 1) ma)))
         out1 #'(()
                  (out-plus-pending 1)
                  (= hi (bit-and (bit-or (<< hi 1) 1) ma))
                  (= lo (bit-and (<< lo 1) ma)))
         outx #'(()
                  (++! pending-bits)
                  (= hi (bit-and (bit-or (<< hi 1) hap) ma))
                  (= lo (bit-and (<< lo 1) ham))))
(let dump nil ;(with-output-file dump "comp.txt"

    (awhile (read-byte i)
            nil
      (with (range (++ (- hi lo)))
        (| (<= range top)
           (error "Range overflow ~A." range))
;        (format dump "~A, hi: ~A, lo: ~A, range: ~A~%"
;                (print-hexbyte ! nil)
;                (print-hexdword hi nil)
;                (print-hexdword lo nil)
;                (print-hexdword range nil))
        (with ((h l) (adapt-sample dump hi lo range a s win !))
          (= hi h
             lo l))
        (loop
          (?
            (< hi ha)       (out0)
            (>= lo ha)      (out1)
            (& (< hi uq)
               (>= lo lq))  (outx)
            (return)))))
    (++! pending-bits)
    (? (< lo lq)
       (out-plus-pending 0)
       (out-plus-pending 1))
    (adotimes 8 (out0)))))

(defun compress (num-bits in out)
  (format t "Arithmetic encoding of '~A' to '~A'…~%" in out)
  (with-io i in
           o out
    (arith-encode num-bits i (make-bit-stream :out o))))

(defun arith-decode (num-bits num-bytes i o)
  (++! num-bytes)
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
         value   0)
        (with-output-file dump "decomp.txt"
    (adotimes num-bits
      (= value (+ (<< value 1) (read-byte i))))
    (while (not (zero? (--! num-bytes)))
           nil
      (with (range  (++ (- hi lo))
             diff   (++ (- value lo))
             cnt    (integer (/ (-- (* diff 256)) range))
             sym    (-- (position-if [< cnt _] s)))
;        (format dump "~A, hi: ~A, lo: ~A, range: ~A, diff: ~A, cnt: ~A~%"
;                (print-hexbyte sym nil)
;                (print-hexdword hi nil)
;                (print-hexdword lo nil)
;                (print-hexdword range nil)
;                (print-hexdword diff nil)
;                (print-hexdword cnt nil))
        (write-byte sym o)
        (with ((h l) (adapt-sample dump hi lo range a s win sym))
          (= hi h
             lo l))
        (loop
          (?
            (< hi ha)
                nil
            (>= lo ha)
              (progn
                (= value (bit-and value ham))
                (= lo (bit-and lo ham))
                (= hi (bit-and hi ham)))
            (& (>= lo lq)
               (< hi uq))
              (progn
                (= value (- value lq))
                (= lo (- lo lq))
                (= hi (- hi lq)))
            (return))
          (= lo (<< lo 1))
          (= hi (<< hi 1))
          (= hi (bit-or hi 1))
          (= value (+ (<< value 1) (| (read-byte i) 0)))))))))

(defun uncompress (num-bits num-bytes in out)
  (format t "Arithmetic decoding of '~A' to '~A'…~%" in out)
  (with-io i in
           o out
    (arith-decode num-bits num-bytes (make-bit-stream :in i) o)))

(defun compress-audio (in out)
  (wav-to-4bit in "obj/hiscore.4bit.bin")
  (compress +window-bits+ "obj/hiscore.4bit.bin" out)
  (uncompress +window-bits+ (length (fetch-file "obj/hiscore.4bit.bin"))
              out "obj/hiscore.decomp.bin")
  (? (equal (fetch-file "obj/hiscore.4bit.bin")
            (fetch-file "obj/hiscore.decomp.bin"))
     (format t "Files match. (De)compression has been successful.~%")
     (error "Files don't match.")))

(compress-audio "obj/intermediate.ram.filtered.wav"
                "obj/hiscore-theme.bin")
;(compress-audio "obj/theme-splash.downsampled.pal.wav"
;                "obj/hiscore-theme.bin")
(quit)
