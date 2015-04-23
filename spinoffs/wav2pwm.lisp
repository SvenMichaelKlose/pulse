(defvar audio_shortest_pulse #x15)
(defvar audio_longest_pulse #x25)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar num-xlats 64)

(defconstant +cpu-cycles-pal+ 1108404)
(defconstant +cpu-cycles-ntsc+ 1020000)

(defun amp (x)
  (= x (* 4 x))
  (- 15
  (alet (integer (/ (* x (/ 256 audio_pulse_width)) 128))
    (? (< 15 !)
       15
       !))))

(defun amplitude-conversions ()
  (maptimes #'amp 64))

(defun print-pwm-info ()
  (format t "Audio resolution: ~A cycles~%" (* 8 audio_pulse_width))
  (format t "~A pulses per second.~%"
          (integer (/ +cpu-cycles-pal+
                      (* 8 (+ audio_shortest_pulse
                            (half audio_pulse_width))))))
  (format t "Amplitude conversions: ~A~%" (amplitude-conversions)))

(defun wav2pwm (out in-file)
  (alet (fetch-file in-file)
    (dotimes (i (length !))
      (princ (code-char (+ audio_shortest_pulse
                           (/ (* (elt ! i) audio_pulse_width) 256)))
             out))))
