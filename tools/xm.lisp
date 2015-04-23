(defstruct xm-header
  module-name
  tracker-name
  version
  header-size
  song-length
  restart-position
  num-channels
  num-patterns
  num-instruments
  flags
  tempo
  bpm
  pattern-order
  patterns)

(defun read-xm-header (in)
  (alet (read-byte-string in 17)
    (| (equal "Extended Module: " !)
       (warn "Stream might not be an XM file. ID is '~A'.~%" !)))
  (aprog1 (make-xm-header
            :module-name  (aprog1 (read-byte-string in 20)
                            (| (== #x1a (read-byte in))
                               (error "Not a S3M file. Incorrect sig1.")))
            :tracker-name      (read-byte-string in 20)
            :version           (read-word in)
            :header-size       (prog1 (read-word in) (read-word in))
            :song-length       (read-word in)
            :restart-position  (read-word in)
            :num-channels      (read-word in)
            :num-patterns      (read-word in)
            :num-instruments   (read-word in)
            :flags             (read-word in)
            :tempo             (read-word in)
            :bpm               (read-word in)
            :pattern-order     (read-byte-array in 256))))

(defun bit? (x n)
  (not (zero? (bit-and (cl:expt 2 n) x))))

(defun read-xm-note (in)
  (with (n        (char-code (peek-char in))
         packed?  (not (zero? (bit-and 128 n))))
    (unless packed?
      (return (read-byte-array in 5)))
    (read-byte in)
    (aprog1 (make-array 7)
      (dotimes (i 7)
        (= (aref ! i) (? (bit? n i)
                         (read-byte in)
                         0))))))

(defstruct xm-pattern
  header-size
  pack-type
  num-rows
  data-size
  rows)

(defun read-xm-row (in num-channels)
  (with-queue q
    (dotimes (j num-channels (list-array (queue-list q)))
      (enqueue q (read-xm-note in)))))

(defun read-xm-rows (in num-channels num-rows)
  (aprog1 (make-array num-rows)
    (dotimes (i num-rows)
      ;(format t "; Row ~A~%" i)
      (= (aref ! i) (read-xm-row in num-channels)))))

(defun read-xm-pattern (in num-channels)
  (aprog1 (make-xm-pattern
            :header-size  (prog1 (read-word in) (read-word in))
            :pack-type    (read-byte in)
            :num-rows     (read-word in)
            :data-size    (read-word in))
    (with-xm-pattern !
;      (format t "; Size:      ~A~%" header-size)
;      (format t "; Pack type: ~A~%" pack-type)
      (format t "; Rows:      ~A~%" num-rows)
;      (format t "; Data size: ~A~%" data-size)
      (unless (== 9 header-size)
        (format t "error")
        (quit))
      (= (xm-pattern-rows !) (read-xm-rows in num-channels num-rows)))))

(defun read-xm-file (in)
  (aprog1 (read-xm-header in)
    (with-xm-header !
      (format t "; Module name:  ~A~%" module-name)
      (format t "; Tracker name: ~A~%" tracker-name)
      (format t "; Version:      ~A~%" (print-hexword version nil))
      (format t "; Song length:  ~A~%" song-length)
      (format t "; Restart pos:  ~A~%" restart-position)
      (format t "; Channels:     ~A~%" num-channels)
      (format t "; Patterns:     ~A~%" num-patterns)
      (format t "; Instruments:  ~A~%" num-instruments)
      (format t "; Flags:        ~A~%" flags)
      (format t "; Tempo:        ~A~%" tempo)
      (format t "; BPM:          ~A~%" bpm)
      (format t "; Pattern order:~%")
      (late-print pattern-order)
      (= (xm-header-patterns !) (make-array num-patterns))
      (dotimes (i num-patterns)
        (format t "; Reading pattern ~A…~%" i)
        (= (aref (xm-header-patterns !) i)
           (read-xm-pattern in num-channels))))
    (format t "; Done.~%")))

(with-input-file i "title.xm" (read-xm-file i))
(quit)
