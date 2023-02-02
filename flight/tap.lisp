(defvar *radio-pilot-length* 16)

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
  (* (/ (cpu-cycles *tv*)
        (radio-rate *tv*))
     256))

(defun radio-average-audio-chunk-cycles ()
  (* radio_average_pulse 8 256))

(defun radio-pilot-length ()
  (* 8 (+ (* *radio-pilot-length* *pulse-short*)
          *pulse-long*
          *pulse-short*)))

(defun radio-average-data-chunk-cycles ()
  (* 1.3 (- (radio-window-cycles)
            (radio-pilot-length)
            (radio-average-audio-chunk-cycles))))

(defun radio-data-size ()
  (with (tap-cycle-resolution   8
         bits-per-byte          8)
    (integer (/ (radio-average-data-chunk-cycles)
                *pulse-long*
                bits-per-byte
                tap-cycle-resolution))))

(defun radio2tap-pilot (out)
  (adotimes *radio-pilot-length*
    (write-byte *pulse-short* out))
  (write-byte *pulse-long* out)
  (write-byte *pulse-short* out))   ; Buffer switch sync.

(defun radio2tap-data (out in-bin)
  (radio2tap-pilot out)
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

(defun radiogap (out x)
  (adotimes ((-- (/ x *pulse-long* 8)))
    (write-byte *pulse-long* out))
  (alet (integer (+ (* *pulse-long* 8) (mod x (* *pulse-long* 8))))
    (unless (zero? !)
      (write-dword (<< ! 8) out))))

(defun radio2tap (out in-wav in-bin &key (gap #x60000))
  (format t "Making radio TAP data for ~A…~% Window cycles: ~A (~A audio, ~A data)~% Data size: ~A~%"
          (symbol-name *tv*)
          (radio-window-cycles)
          (radio-average-audio-chunk-cycles)
          (radio-average-data-chunk-cycles)
          (radio-data-size))
  (= (stream-track-input-location? in-wav) nil)
  (= (stream-track-input-location? in-bin) nil)
  (adotimes 44
    (read-byte in-wav))
  (awhen gap
    (radiogap out !))
  (let window-cycles (radio-window-cycles)
    (while (peek-char in-bin)
           nil
      (with (t-data   (radio2tap-data out in-bin)
             t-audio  (? (peek-char in-bin)
                         (radio2tap-audio out in-wav)
                         0)
             total    (* 8 (+ t-data t-audio)))
        (format t "Chunk cycles: ~A of ~A, data: ~A, audio: ~A (~A)"
                (/ total 8) (/ window-cycles 8)
                t-data t-audio (/ t-audio 256))
        (? (< total window-cycles)
           (when (peek-char in-bin)
             (alet (integer (- window-cycles total))
               (format t ", filling up ~A" (/ ! 8))
               (radiogap out !)))
           (error "~%Chunk overflow. No sync pulse."))
        (terpri)))))
