(defun read-byte-statement (i)
  (@ [with-stream-string s _
       (? (eq #\$ (peek-char s))
          (progn
            (read-char s)
            (read-hex s))
          (read-number s))]
     (split "," (subseq i 7) :test #'string==)))

(defun read-bytes (i)
  (with (f #'(()
               (alet (read-line i)
                 (unless (string== ! (format nil "~%"))
                   (+ (read-byte-statement !)
                      (f))))))
    (list-string (f))))

(defun read-screen-designer-file (name)
  (with (char-data nil
         screen    nil)
    (with-input-file i name
      (with (f #'(()
                   (alet (read-line i)
                     (?
                       (head? ! ";char data")     (& (= char-data (read-bytes i))
                                                     (f))
                       (head? ! ";screen data0")  (& (read-line i)
                                                     (= screen (read-bytes i)) (f))
                       (head? ! ";colour data0")  (values char-data
                                                          screen
                                                          (& (read-line i)
                                                             (read-bytes i)))
                       (f)))))
        (f)))))
