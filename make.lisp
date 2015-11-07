(= *model* :vic-20)

(defvar *virtual?* nil)
(defvar *coinop?* nil)
(defvar *video?* nil)
(defvar *make-wav?* nil)
(defvar *only-pal-vic?* nil)

(defvar *bandwidth* 16)
(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(defvar audio_shortest_pulse #x18)
(defvar audio_longest_pulse #x28)
(defvar frame_sync_width #x08)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar audio_average_pulse (+ audio_shortest_pulse (half audio_pulse_width)))

(load "secondary-loader/bin2pottap.lisp")
(load "nipkow/src/wav2pwm.lisp")
(load "game/files.lisp")

(defun check-zeropage-size ()
  (when (< #x100 *pc*)
    (error "Zero page overflow by ~A bytes." (- *pc* #x100))))

(defun make-wav (name file gain bass tv)
  (sb-ext:run-program "/usr/bin/mplayer"
    (list "-vo" "null" "-vc" "null" "-ao" (+ "pcm:fast:file=obj/" name "." (downcase (symbol-name tv)) ".wav") file)
    :pty cl:*standard-output*)
  (sb-ext:run-program "/usr/bin/sox"
    (list (+ "obj/" name "." (downcase (symbol-name tv)) ".wav")
          (+ "obj/" name "." (downcase (symbol-name tv)) ".filtered.wav")
          "bass" bass
          "lowpass" (princ (half (pwm-pulse-rate tv)) nil)
          "compand" "0.3,1" "6:-70,-60,-20" "-1" "-90" "0.2" "gain" gain)
    :pty cl:*standard-output*))

(defun make-conversion (name tv)
  (sb-ext:run-program "/usr/bin/sox"
    (list (+ "obj/" name "." (downcase (symbol-name tv)) ".filtered.wav")
          "-c" "1"
          "-b" "16"
          "-r" (princ (pwm-pulse-rate tv) nil)
          (+ "obj/" name "_downsampled_" (downcase (symbol-name tv)) ".wav"))
    :pty cl:*standard-output*))

(defun make-audio (name file gain bass)
  (make-wav name file gain bass :pal)
  (make-conversion name :pal)
  (unless *only-pal-vic?*
    (make-wav name file gain bass :ntsc)
    (make-conversion name :ntsc)))

(make-audio "theme1" "media/boray_no_syrup.mp3" "3" "-64")
(make-audio "theme2" "media/theme-lukas.mp3" "3" "-72")

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-output-file in   in-file
                          out  out-file
    (tap2wav in out)))

(defun make (to files cmds)
  (apply #'assemble-files to files)
  (make-vice-commands cmds "break .stop"))

(defun make-game (version file cmds)
  (make file
        (@ [+ "game/" _] (pulse-files version))
        cmds))

(defvar *splash-start* #x1234)
(defvar *tape-loader-start* #x1234)

(defun make-model-detection ()
  (make "obj/model-detection.bin"
        '("primary-loader/models.asm"
          "primary-loader/model-detection.asm")
        "obj/model-detection.vice.txt"))
(make-model-detection)

(defun make-loader-prg ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/loader." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/models.asm"
            "primary-loader/zeropage.asm"
            "bender/vic-20/basic-loader.asm"
            "primary-loader/main.asm"
            "secondary-loader/start.asm"
            "secondary-loader/loader.asm")
          (+ "obj/loader." ! ".prg.vice.txt"))))

(defun make-splash-gfx ()
  (make "obj/splash-gfx.bin"
        '("splash/gfx.asm")
        "obj/splash-gfx.bin.vice.txt"))
(make-splash-gfx)

(defun break-up-splash-gfx ()
  (put-file "obj/splash.chars.0-127.bin" (subseq (fetch-file "obj/splash-gfx.bin") 0 1024))
  (put-file "obj/splash.chars.128-159.bin" (subseq (fetch-file "obj/splash-gfx.bin") 1024 (+ 1024 256)))
  (put-file "obj/splash.screen.bin" (alet (+ 1024 256) (subseq (fetch-file "obj/splash-gfx.bin") ! (+ ! 506))))
  (put-file "obj/splash.colors.bin" (alet (+ 1024 256 528) (subseq (fetch-file "obj/splash-gfx.bin") !))))
(break-up-splash-gfx)

(defun glued-game-and-splash-gfx (game)
  (+ (subseq (fetch-file game) 0 1024)
     (fetch-file "obj/splash.chars.128-159.bin")
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
          (+ "obj/splash." ! ".prg.vice.txt"))))

(defun make-3k (imported-labels)
  (with-temporary *imported-labels* imported-labels
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/3k." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "primary-loader/zeropage.asm"
              "expanded/3k.asm"
              "expanded/load-3k.asm"
              "secondary-loader/start.asm"
              "expanded/patch-3k.asm"
              "expanded/sprites-vic-preshifted.asm")
            (+ "obj/3k." ! ".prg.vice.txt")))))

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

(defvar *tv* nil)
(defvar *current-game* nil)

(defun make-loaders (tv imported-labels)
  (with-temporary *imported-labels* imported-labels
    (make-splash-prg)
    (with (splash-size  (- (get-label 'relocated_splash_end)
                           (get-label 'relocated_splash)))
      (format t "Compressing splash with exomizer...~%")
      (sb-ext:run-program "/usr/local/bin/exomizer"
                          `("sfx" "$1002"
                            "-t" "20"
                            "-n"
                            "-Di_load_addr=$1002"
                            "-o" ,(+ "obj/splash.crunched." tv ".prg")
                            ,(+ "obj/splash." tv ".prg"))
                          :pty cl:*standard-output*)
      (alet (get-label 'memory_end)
        (make-3k imported-labels)
        (make-loader-prg)
        (values splash-size !)))))

(defun make-all-games (tv-standard)
  (with-temporary *tv* tv-standard
    (let tv (downcase (symbol-name *tv*))
      (= *current-game* (+ "obj/game.crunched." tv ".prg"))
      (make-game :tap
                 (+ "obj/game." tv ".prg")
                 (+ "obj/game." tv ".vice.txt"))
      (format t "Compressing game with exomizer...~%")
      (sb-ext:run-program "/usr/local/bin/exomizer"
                          `("sfx" "$1002"
                            "-t" "20"
                            "-n"
                            "-Di_load_addr=$1002"
                            "-o" ,(+ "obj/game.crunched." tv ".prg")
                            ,(+ "obj/game." tv ".prg"))
                          :pty cl:*standard-output*)
      (let game-labels (get-labels)
        (when (== *splash-start* #x1234)
          ; Find out how much space the loader will occupy right below the screen.
          (with ((splash-size memory-end) (make-loaders tv game-labels))
            (= *tape-loader-start* (- memory-end (- (get-label 'loader_end) (get-label 'tape_loader))))
            (= *splash-start* (- *tape-loader-start* splash-size))))
        (make-loaders tv game-labels))
      (with-output-file o (+ "compiled/pulse." tv ".tap")
        (write-tap o
            (+ (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/loader." tv ".prg"))))
                           (+ (padded-name (+ "PULSE (" (upcase tv) ")"))
                              (fetch-file "obj/model-detection.bin"))
                           :start #x1001)
               (bin2pottap (string-list (fetch-file (+ "obj/3k." tv ".prg"))))
               (bin2pottap (string-list (fetch-file (+ "obj/splash.crunched." tv ".prg"))))
               (bin2pottap (string-list (glued-game-and-splash-gfx *current-game*)))))
        (adotimes 256 (princ (code-char #x20) o))
        (wav2pwm o (+ "obj/theme1_downsampled_" tv ".wav") :pause-before 0)
        (wav2pwm o (+ "obj/theme2_downsampled_" tv ".wav")))
      (sb-ext:run-program "/usr/bin/zip"
                          (list (+ "compiled/pulse." tv ".tap.zip")
                                (+ "compiled/pulse." tv ".tap"))
                          :pty cl:*standard-output*))))

(defvar *tape-release?* nil)

(with-temporary *tape-release?* t
  (make-all-games :pal))
(unless *only-pal-vic?*
  (with-temporary *tape-release?* t
    (make-all-games :ntsc))
  (make-game :prg "pulse.prg" "obj/pulse.vice.txt")
  (with-temporary *virtual?* t
    (make-game :virtual "compiled/virtual.bin" "obj/virtual.vice.txt"))
  (with-temporary *virtual?* t
    (with-temporary *coinop?* t
      (make-game :virtual "compiled/coinop.bin" "obj/coinop.vice.txt"))))

(print-pwm-info)

(defun tap-rate (tv avg-len)
  ; XXX Need INTEGER here because tré's FRACTION-CHARS is buggered.
  (integer (/ (? (eq tv :pal)
                 +cpu-cycles-pal+
                 +cpu-cycles-ntsc+)
              (* 8 avg-len))))

(alet (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))
  (format t "Baud rates: ~A (NTSC), ~A (PAL)~%"
          (tap-rate :ntsc !) (tap-rate :pal !)))

(when *make-wav?*
  (format t "Making PAL WAV file...~%")
  (with-input-file i "compiled/pulse.pal.tap"
    (with-output-file o "compiled/pulse.pal.wav"
      (tap2wav i o)))

  (format t "Making NTSC WAV file...~%")
  (with-input-file i "compiled/pulse.ntsc.tap"
    (with-output-file o "compiled/pulse.ntsc.wav"
      (tap2wav i o))))

(format t "Done making 'Pulse'. See directory 'compiled/'.~%")

(quit)
