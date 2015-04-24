(defconstant +tv+ 'ntsc)

(defconstant +cpu-cycles-pal+ 1108404)
(defconstant +cpu-cycles-ntsc+ 1020000)

(defconstant +cpu-cycles+ (? (eq +tv+ 'pal)
                             +cpu-cycles-pal+
                             +cpu-cycles-ntsc+))

(defvar audio_shortest_pulse (? (eq +tv+ 'pal) #x18 #x18))
(defvar audio_longest_pulse (? (eq +tv+ 'pal) #x28 #x28))
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar num-xlats 64)

(defun amp (x)
  (= x (* 4 x))
  (- 15
  (alet (integer (/ (* x (/ 256 audio_pulse_width)) 128))
    (? (< 15 !)
       15
       !))))

(defun amplitude-conversions ()
  (maptimes #'amp 64))

(defun pwm-pulse-rate ()
  (integer (/ +cpu-cycles+
              (* 8 (+ audio_shortest_pulse (half audio_pulse_width))))))

(defun print-pwm-info ()
  (format t "Audio resolution: ~A cycles~%" (* 8 audio_pulse_width))
  (format t "~A pulses per second.~%" (pwm-pulse-rate))
  (format t "Amplitude conversions: ~A~%" (amplitude-conversions)))

(defun unsigned (x)
  (+ x (? (< 127 x) -128 128)))

(defun wav2pwm (out in-file)
  (alet (fetch-file in-file)
    (dotimes (i (length !))
      (unless (zero? (mod i 2))
        (princ (code-char (+ audio_shortest_pulse
                             (/ (* (unsigned (elt ! i)) audio_pulse_width) 256)))
               out)))))
