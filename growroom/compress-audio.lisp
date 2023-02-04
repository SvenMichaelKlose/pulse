; Based on https://marknelson.us/posts/2014/10/19/data-compression-with-arithmetic-coding.html

(cl:proclaim '(cl:optimize (cl:speed 1) (cl:space 0) (cl:safety 3) (cl:debug 3)))
;(cl:proclaim '(cl:optimize (cl:speed 3) (cl:space 0) (cl:safety 0) (cl:debug 0)))

(defconstant +symbols+ 17)
(defconstant *esc* 16)
(defconstant +window-size+ 256)
(defconstant +precision-bits+ 16)

(defstruct model
  occs
  sums
)

(defun wav-to-4bit (from to)
  (format t "Converting '~A' to 4-bit '~A'…~%" from to)
  (with-io i from
           o to
    (adotimes 44 (read-byte i))
    (awhile (read-word i)
            nil
      (write-byte (bit-xor (>> ! 12) 8) o))))

(defun init-audio-model ()
  (make-model :occs (list-array (maptimes [identity 0] +symbols+))
              :sums (list-array (maptimes [identity 0] (++ +symbols+)))))

(defun update-audio-model (m x v)
  (= (aref (model-occs m) x) (+ v (aref (model-occs m) x)))
  (++! x)
  (while (not (== x (++ +symbols+)))
         nil
    (= (aref (model-sums m) x) (+ v (aref (model-sums m) x)))
    (++! x)))

(defun make-window (m)
  (dotimes (i +symbols+)
    (update-audio-model m i 1))
  (aprog1 (make-queue)
    (dotimes (i +window-size+)
      (let sym (mod i +symbols+)
        (update-audio-model m sym 1)
        (enqueue ! sym)))))

(defun adapt-sample (lo range m win sym)
  (with (total (aref (model-sums m) +symbols+)
         h     (-- (+ lo (integer (/ (* range (aref (model-sums m) (++ sym))) total))))
         l     (+ lo (integer (/ (* range (aref (model-sums m) sym)) total))))
    (update-audio-model m (queue-pop win) -1)
    (update-audio-model m sym 1)
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
         m      (init-audio-model)
         win    (make-window m)
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
                (with ((h l) (adapt-sample lo range m win _))
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
;      (unless (position ! (queue-list win))
;        (enc *esc*))
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
         m      (init-audio-model)
         win    (make-window m)
         value   0
         dec    #'(()
                    (with (range  (++ (- hi lo))
                           diff   (++ (- value lo))
                           cnt    (integer (/ (-- (* diff (aref (model-sums m) +symbols+))) range))
                           sym    (-- (position-if [< cnt _] (model-sums m)))
                           (h l)  (adapt-sample lo range m win sym))
                      (= hi h
                         lo l)
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
                          (return sym))
                        (= lo (<< lo 1))
                        (= hi (<< hi 1))
                        (= hi (bit-or hi 1))
                        (= value (+ (<< value 1) (| (read-byte i) 0))))
                      sym)))
    (adotimes num-bits
      (= value (+ (<< value 1) (read-byte i))))
    (while (not (zero? (--! num-bytes)))
           nil
        ;(unless (== sym *esc*) (write-byte sym o))
      (write-byte (dec) o))))

(defun uncompress (num-bits num-bytes in out)
  (format t "Arithmetic decoding of '~A' to '~A'…~%" in out)
  (with-io i in
           o out
    (arith-decode num-bits num-bytes (make-bit-stream :in i) o)))

(defun compress-file (in out)
  (compress +precision-bits+ in out)
  (uncompress +precision-bits+ (length (fetch-file in)) out "obj/test-audio.decomp.tmp")
  (? (equal (fetch-file in)
            (fetch-file "obj/test-audio.decomp.tmp"))
     (format t "Files match. (De)compression has been successful.~%")
     (error "Files don't match.")))

;(compress-file "growroom/arukanoido"
;               "obj/aru.comp")
(wav-to-4bit "obj/radio.downsampled.pal.wav" "obj/test-audio.4bit.bin")
(compress-file "obj/test-audio.4bit.bin"
                "obj/test-audio.ari.bin")

(quit)
