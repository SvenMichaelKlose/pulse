(load "spinoffs/wav2pwm.lisp")

(print-pwm-info)
(put-file "obj/_make.sh"
  (format nil
    (+ "mplayer -vo null -vc null -ao pcm:fast:file=obj/ohne_dich.wav ~A~%"
       "sox obj/ohne_dich.wav obj/ohne_dich_filtered.wav bass ~A lowpass ~A compand 0.3,1 6:-70,-60,-20 -3 -90 0.2 gain 4~%"
       "sox obj/ohne_dich_filtered.wav -c 1 -b 8 -r ~A -u obj/ohne_dich_8bit.wav~%")
    "spinoffs/ohne_dich.mp3"
    -72     ; Bass reduction.
    2000  ;(half (pwm-pulse-rate))
    (pwm-pulse-rate)))

(quit)
