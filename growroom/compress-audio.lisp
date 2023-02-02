; Based on https://marknelson.us/posts/2014/10/19/data-compression-with-arithmetic-coding.html

;(cl:proclaim '(cl:optimize (cl:speed 1) (cl:space 0) (cl:safety 3) (cl:debug 3)))
(cl:proclaim '(cl:optimize (cl:speed 3) (cl:space 0) (cl:safety 0) (cl:debug 0)))

(defconstant +symbols+ 16)
(defconstant +window-size+ 16)
(defconstant +precision-bits+ 16)

(defun wav-to-4bit (from to)
  (format t "Converting '~A' to 4-bit '~A'…~%" from to)
  (with-io i from
           o to
    (adotimes 44 (read-byte i))
    (awhile (read-word i)
            nil
      (write-byte (bit-xor (>> ! 12) 8) o))))

(defun init-audio-model ()
  (values (list-array (maptimes [identity 0] +symbols+))
          (list-array (maptimes [identity 0] (++ +symbols+)))))

(defun update-audio-model (a s x v)
  (= (aref a x) (+ v (aref a x)))
  (++! x)
  (while (not (== x (++ +symbols+)))
         nil
    (= (aref s x) (+ v (aref s x)))
    (++! x)))

(defun make-window (a s)
  (dotimes (i +symbols+)
    (update-audio-model a s i 1))
  (aprog1 (make-queue)
    (dotimes (i +window-size+)
      (let sym (mod i +symbols+)
        (update-audio-model a s sym 1)
        (enqueue ! sym)))))

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
         win    (make-window a s)
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
         enc [(with (range (++ (- hi lo)))
                (| (<= range top)
                   (error "Range overflow ~A." range))
                (with ((h l) (adapt-sample lo range a s win _))
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
                    (return))))])
    (awhile (read-byte i)
            nil
      (enc !))
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
         win    (make-window a s)
         value   0)
    (adotimes num-bits
      (= value (+ (<< value 1) (read-byte i))))
    (while (not (zero? (--! num-bytes)))
           nil
      (with (range  (++ (- hi lo))
             diff   (++ (- value lo))
             cnt    (integer (/ (-- (* diff (aref s +symbols+))) range))
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

(defun compress-file (in out)
  (compress +precision-bits+ in out)
  (uncompress +precision-bits+ (length (fetch-file in)) out "obj/compress.tmp")
  (? (equal (fetch-file in)
            (fetch-file "obj/compress.tmp"))
     (format t "Files match. (De)compression has been successful.~%")
     (error "Files don't match.")))

;(compress-file "growroom/arukanoido"
;               "obj/aru.comp")
(wav-to-4bit "obj/theme-splash.downsampled.pal.wav" "obj/test-audio.4bit.bin")
(compress-file "obj/test-audio.4bit.bin"
                "obj/test-audio.ari.bin")

(quit)
