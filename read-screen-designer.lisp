(defun read-byte-statement (i)
  (@ [with-stream-string s _
       (? (eq #\$ (peek-char s))
          (progn
            (read-char s)
            (code-char (read-hex s)))
          (code-char (read-number s)))]
     (split "," (subseq i 7) :test #'string==)))

(defun read-bytes (i)
  (with (f #'(()
               (alet (read-line i)
                 (unless (string== ! (format nil "~%"))
                   (+ (read-byte-statement !)
                      (f))))))
    (list-string (f))))

(defun read-screen-designer-file (name)
  (with (char-data  (make-queue)
         screens    (make-queue)
         colours    (make-queue))
    (with-input-file i name
      (with (f #'(()
                   (alet (read-line i)
                     (?
                       (not !) (values (queue-list char-data)
                                       (queue-list screens)
                                       (queue-list colours))
                       (head? ! ";char data")   (& (enqueue char-data (read-bytes i))
                                                   (f))
                       (head? ! ";screen data") (& (read-line i)
                                                    (enqueue screens (read-bytes i))
                                                    (f))
                       (head? ! ";colour data") (& (read-line i)
                                                   (enqueue colours (read-bytes i))
                                                   (f))
                       (f)))))
        (f)))))
