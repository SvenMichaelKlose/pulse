
;(cl:proclaim '(cl:optimize (cl:speed 0) (cl:space 0) (cl:safety 3) (cl:debug 3)))
(cl:proclaim '(cl:optimize (cl:speed 3) (cl:space 0) (cl:safety 0) (cl:debug 0)))

(defconstant +symbols+ 16)
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
  (values (list-array (maptimes [0 identity (integer (/ 256 +symbols+))] +symbols+))
          (list-array (maptimes [* _ (integer (/ 256 +symbols+))] (++ +symbols+)))))

(defun update-audio-model (a s x v)
  (unless (zero? (+ v (aref a x)))
    (= (aref a x) (+ v (aref a x)))
    (++! x)
    (while (not (== x (++ +symbols+)))
           nil
      (= (aref s x) (+ v (aref s x)))
      (++! x))))

(defun make-window ()
  (aprog1 (make-queue)
    (dotimes (i +symbols+)
      (enqueue ! (mod i +symbols+)))))

(defun adapt-sample (lo range a s win sym)
  (with (total (aref s +symbols+)
         h     (-- (+ lo (integer (/ (* range (aref s (++ sym))) total))))
         l     (+ lo (integer (/ (* range (aref s sym)) total))))
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
                  (= lo (bit-and (<< lo 1) ma))))
    (awhile (read-byte i)
            nil
      (with (range (++ (- hi lo)))
        (| (<= range top)
           (error "Range overflow ~A." range))
        (with ((h l) (adapt-sample lo range a s win !))
          (= hi h
             lo l))
        (loop
          (?
            (< hi ha)
              (out0)
            (>= lo ha)
              (progn
                (out-plus-pending 1)
                (= hi (bit-and (bit-or (<< hi 1) 1) ma))
                (= lo (bit-and (<< lo 1) ma)))
            (& (< hi uq)
               (>= lo lq))
              (progn
                (++! pending-bits)
                (= hi (bit-and (bit-or (<< hi 1) hap) ma))
                (= lo (bit-and (<< lo 1) ham)))
            (return)))))
    (++! pending-bits)
    (? (< lo lq)
       (out-plus-pending 0)
       (out-plus-pending 1))
    (adotimes 8 (out0))))

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
         ham    (-- ha)
         uq     (* 3 (/ top 4))
         lq     (/ top 4)
         hi     ma
         lo     0
         (a s)  (init-audio-model)
         win    (make-window)
         value   0)
    (adotimes num-bits
      (= value (+ (<< value 1) (read-byte i))))
    (while (not (zero? (--! num-bytes)))
           nil
      (with (range  (++ (- hi lo))
             diff   (++ (- value lo))
             cnt    (integer (/ (-- (* diff 256)) range))
             sym    (-- (position-if [< cnt _] s)))
        (write-byte sym o)
        (with ((h l) (adapt-sample lo range a s win sym))
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
          (= value (+ (<< value 1) (| (read-byte i) 0))))))))

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

;(compress-audio "growroom/arukanoido"
;                "growroom/aru.comp")
(compress-audio "obj/theme-splash.downsampled.pal.wav"
                "obj/test-audio.ari.bin")
;(compress-audio "obj/theme-splash.downsampled.pal.wav"
;                "obj/hiscore-theme.bin")
(quit)
