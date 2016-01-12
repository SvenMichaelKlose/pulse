; Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defun radio2tap-byte (out in-wav x)
  (dotimes (j 8)
    (write-byte (+ (? (zero? (bit-and x 1))
                      *radio-pulse-short*
                      *radio-pulse-long*)
                   (| (awhen (read-word in-wav)
                        (unclip (bit-xor (>> ! 12) 8) 15))
                      8))
                out)
    (= x (>> x 1))))

(defun radio2tap (out in-wav in-bin &key (with-lead-in? t))
  (adotimes 44
    (read-byte in-wav))
  (when with-lead-in?
    (write-dword #x08000000 out)
    (adotimes 32 (write-byte *pulse-short* out)))
  (write-byte *pulse-long* out)
  (awhile (read-byte in-bin)
          nil
    (radio2tap-byte out in-wav !)))
