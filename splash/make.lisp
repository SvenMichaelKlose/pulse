(defvar *bandwidth* 16)

(defvar audio_shortest_pulse #x18)
(defvar audio_longest_pulse #x28)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar audio_average_pulse (+ audio_shortest_pulse (half audio_pulse_width)))

(defun make-tape-audio (tv name file gain bass)
  (make-wav name file gain bass tv (pwm-pulse-rate tv))
  (make-conversion name tv (pwm-pulse-rate tv)))

(defconstant +splash-chars-0-127+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    (subseq chars 0 1024)))

(defconstant +splash-chars-128-159+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    (subseq chars 1024 (+ 1024 256))))

(defconstant +splash-screen+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    screen))

(defconstant +splash-colours+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    colours))

(defun glued-game-and-splash-gfx (game)
  (+ (subseq (fetch-file game) 0 1024)
     +splash-chars-128-159+
     (subseq (fetch-file game) (+ 1024 256))))

(defun make-splash-prg ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/splash." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/models.asm"
            "primary-loader/zeropage.asm"
            "splash/main.asm"
            "secondary-loader/start.asm"
            "splash/splash.asm"
            "splash/audio-player.asm")
          (+ "obj/splash." ! ".prg.vice.txt"))
    (exomize (+ "obj/splash." ! ".prg")
             (+ "obj/splash.crunched." ! ".prg")
             "1002" "20")))
