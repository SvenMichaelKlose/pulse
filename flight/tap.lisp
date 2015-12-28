; Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defun radio2tap-audio (out in-wav)
  (let acc radio_shortest_pulse
    (write-byte radio_shortest_pulse out)
    (adotimes 256
      (let v (+ radio_shortest_pulse
                (| (awhen (read-word in-wav)
                     (unclip (bit-xor (>> ! 12) 8) 15))
                   8))
        (write-byte v out)
        (+! acc v)))
    acc))

(defun radio-window-cycles ()
  (integer (* (/ (cpu-cycles *tv*)
                 (radio-rate *tv*))
              512)))

(defun radio-data-size ()
  (with (tap-cycle-resolution   8
         bits-per-byte          8)
    (integer (/ (half (radio-window-cycles))
                tap-cycle-resolution
                *pulse-long*
                bits-per-byte))))

(defun radio2tap-data (out in-bin)
  (let acc 0
    (adotimes ((radio-data-size))
      (when (peek-char in-bin)
            nil
        (let x (read-char in-bin)
          (dotimes (j 8)
            (let v (? (zero? (bit-and x 1))
                      *pulse-short*
                      *pulse-long*)
              (write-byte v out)
              (+! acc v))
            (= x (>> x 1))))))
    acc))

(defun radio2tap (out in-wav in-bin &key (gap #x08000000) (lead-in? t))
  (format t "Making radio TAP data for ~A…~% Window cycles: ~A~% Data size: ~A~%"
          (symbol-name *tv*) (radio-window-cycles) (radio-data-size))
  (adotimes 44
    (read-byte in-wav))
  (awhen gap
    (write-dword ! out))
  (when lead-in?
    (adotimes 32 (write-byte *pulse-short* out))
    (write-byte *pulse-long* out))
  (let window-cycles (radio-window-cycles)
    (while (peek-char in-bin)
           nil
      (with (t-data   (radio2tap-data out in-bin)
             t-audio  (radio2tap-audio out in-wav)
             total    (* 8 (+ t-data t-audio)))
        (format t "Chunk cycles: ~A of ~A, data: ~A, audio: ~A (~A)"
                (/ total 8) (/ window-cycles 8)
                t-data t-audio (/ t-audio 256))
        (? (< total window-cycles)
           (let r (integer (- window-cycles total))
             (format t ", filling up ~A" (/ r 8))
             (write-dword (<< r 8) out))
           (error "~%Chunk overflow. No sync pulse."))
        (terpri)))))
