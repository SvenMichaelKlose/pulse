(load "bender/vic-20/cpu-cycles.lisp")

(defun bin2pottap-byte (q i)
  (when (< i 0)
    (= i (+ 256 i)))
   (dotimes (j 8)
     (enqueue q (code-char (? (zero? (bit-and i 1))
                              *pulse-short*
                              *pulse-long*)))
     (= i (>> i 1))))

(defun bin2pottap (x)
  (with-queue q
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x00))
    (enqueue q (code-char #x04))
    (enqueue q (code-char #x30))
    (dolist (i x (list-string (queue-list q)))
      (bin2pottap-byte q i))))
