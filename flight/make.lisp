(defvar *earth-chars* nil)
(defvar *earth-screen* nil)
(defvar *earth-colours* nil)
(when (make-version? :pal-tape :ntsc-tape)
  (with ((chars screen colours) (read-screen-designer-file "media/flight/earth.txt"))
    (= *earth-chars* chars.)
    (= *earth-screen* screen.)
    (= *earth-colours* colours.)))

(defvar radio_shortest_pulse #x18)
(defvar radio_longest_pulse #x28)
(defvar radio_pulse_width (- radio_longest_pulse radio_shortest_pulse))
(defvar radio_average_pulse (+ radio_shortest_pulse (half radio_pulse_width)))

(defun radio-rate (tv)
  2000)

(defun make-radio-tap (to in-wav bin)
  (with-output-file out to
    (with-input-file in-bin bin
      (radio2tap out in-wav in-bin))))

(defun make-radio-wav (tv)
  (format t "Making radio…~%")
  (make-filtered-wav "radio" "3" "-32" tv (radio-rate tv))
  (make-conversion "radio" tv (radio-rate tv))
  (alet (downcase (symbol-name tv))
    (with-input-file in-wav (+ "obj/radio.downsampled." ! ".wav")
      (make-radio-tap "obj/radio0.tap" in-wav (+ "obj/8k.crunched." ! ".prg"))
      (make-radio-tap "obj/radio1.tap" in-wav (+ "obj/8k.crunched." ! ".prg"))
      (make-radio-tap "obj/radio2.tap" in-wav (+ "obj/8k.crunched." ! ".prg")))))

(defun make-flight ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/flight." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/models.asm"
            "flight/zeropage.asm"
            "flight/start.asm"
            "flight/load-sequence.asm"
            "flight/play-sample.asm"
            "flight/flight.asm"
            "flight/draw.asm"
            "flight/loader.asm"
            "game/screen.asm"
            "game/high-segment.asm"
            "secondary-loader/start.asm")
          (+ "obj/flight." ! ".prg.vice.txt"))
    (exomize (+ "obj/flight." ! ".prg")
             (+ "obj/flight.crunched." ! ".prg")
             "1002" "20")))
