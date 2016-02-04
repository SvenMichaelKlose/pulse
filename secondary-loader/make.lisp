(defun tap-rate (tv)                                                                          
    (integer (/ (? (eq tv :pal)
                   +cpu-cycles-pal+
                   +cpu-cycles-ntsc+)
                (* 8 *pulse-average*))))

(defun print-bitrate-info ()
  (format t "Fast loader rates:~% ~A Bd (NTSC)~% ~A Bd (PAL)~%"
            (tap-rate :ntsc) (tap-rate :pal)))

(defun fastloader-byte (q i)
  (when (< i 0)
    (= i (+ 256 i)))
   (dotimes (j 8)
     (enqueue q (? (zero? (bit-and i 1))
                   *pulse-short*
                   *pulse-long*))
     (= i (>> i 1))))

(defun fastloader-block (x &key (gap #x080000))
  (with-queue q
    (enqueue q #x00)
    (enqueue q (bit-and gap 255))
    (enqueue q (bit-and (>> gap 8) 255))
    (enqueue q (>> gap 16))
    (adotimes 128 (enqueue q *pulse-short*))
    (enqueue q *pulse-long*)
    (dosequence (i x (list-string (queue-list q)))
      (fastloader-byte q i))))
