(load "spinoffs/wav2pwm.lisp")

(defun make-conversion (tv file bass)
  (format nil
    (+ "mplayer -vo null -vc null -ao pcm:fast:file=obj/ohne_dich.wav ~A~%"
       "sox obj/ohne_dich.wav obj/ohne_dich_filtered.wav bass ~A lowpass 2000 compand 0.3,1 6:-70,-60,-20 -5 -90 0.2 gain 4~%"
       "sox obj/ohne_dich_filtered.wav -c 1 -b 16 -r ~A obj/ohne_dich_downsampled_~A.wav~%")
    file bass (pwm-pulse-rate tv) (downcase (symbol-name tv))))

(print-pwm-info)
(put-file "obj/_make.sh"
  (+ (make-conversion :pal "spinoffs/ohne_dich.mp3" -56)
     (make-conversion :ntsc "spinoffs/ohne_dich.mp3" -56)))

(quit)
