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
    (adotimes 32 (enqueue q *pulse-short*))
    (enqueue q *pulse-long*)
    (dosequence (i x (list-string (queue-list q)))
      (fastloader-byte q i))))
