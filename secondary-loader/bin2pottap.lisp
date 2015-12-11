(load "bender/vic-20/cpu-cycles.lisp")

(defun bin2pottap-byte (q i)
  (when (< i 0)
    (= i (+ 256 i)))
   (dotimes (j 8)
     (enqueue q (code-char (? (zero? (bit-and i 1))
                              *pulse-short*
                              *pulse-long*)))
     (= i (>> i 1))))

(defun bin2pottap (x &key (gap #x080000))
  (with-queue q
    (enqueue q (code-char #x00))
    (enqueue q (code-char (bit-and gap 255)))
    (enqueue q (code-char (bit-and (>> gap 8) 255)))
    (enqueue q (code-char (>> gap 16)))
    (adotimes 32 (enqueue q *pulse-short*))
    (enqueue q *pulse-long*)
    (dolist (i x (list-string (queue-list q)))
      (bin2pottap-byte q i))))
