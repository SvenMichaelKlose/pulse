(load "bender/vic-20/cpu-cycles.lisp")

(defvar *video?* nil)

(defvar audio_shortest_pulse #x18)
(defvar audio_longest_pulse #x28)
(defvar frame_sync_width #x08)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
;(defvar num-xlats 64)

(defun amp (x)
  (= x (* 4 x))
  (- 15
  (alet (integer (/ (* x (/ 256 audio_pulse_width)) 128))
    (? (< 15 !)
       15
       !))))

(defun amplitude-conversions ()
  (maptimes #'amp 64))

(defun pwm-pulse-rate (tv)
  ; XXX Need INTEGER here because tré's FRACTION-CHARS is buggered.
  (integer (/ (? (eq tv :pal)
                 +cpu-cycles-pal+
                 +cpu-cycles-ntsc+)
              (* 8 (+ audio_shortest_pulse (half audio_pulse_width))))))

(defun print-pwm-info ()
  (format t "Audio resolution: ~A cycles~%" (* 8 audio_pulse_width))
  (format t "~A pulses per second (PAL).~%" (pwm-pulse-rate :pal))
  (format t "~A pulses per second (NTSC).~%" (pwm-pulse-rate :ntsc))
  (format t "Amplitude conversions: ~A~%" (amplitude-conversions)))

(defun unsigned (x)
  (+ x (? (< 127 x) -128 128)))

(defun wav2pwm (out in-file &optional video)
  (alet (fetch-file in-file)
    (dotimes (i (length !))
      (unless (zero? (mod i 2))
        (princ (code-char (+ audio_shortest_pulse
                             (/ (* (unsigned (elt ! i)) audio_pulse_width) 256)))
               out)
        (when (& *video?*
                 (peek-char video))
          (princ (read-char video) out))))))

(defun wav42pwm (out in-file)
  (alet (fetch-file in-file)
    (dotimes (i (length !))
      (alet (elt ! i)
        (princ (code-char (+ audio_shortest_pulse (>> ! 4))) out)
        (princ (code-char (+ audio_shortest_pulse (bit-and ! 15))) out)))))
