(= *model* :vic-20)
(defvar *make-wav?* nil)
(defvar *only-pal-vic?* nil)
(defvar *make-shadowvic-versions?* nil)

(defvar *virtual?* nil)
(defvar *video?* nil)
(defvar *tape-release?* nil)
(defvar *tv* nil)
(defvar *current-game* nil)

(defvar *bandwidth* 16)
(defvar *pulse-short* #x28)
(defvar *pulse-long* #x38)
(defvar *tape-pulse* (* 8 (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))))

(defvar audio_shortest_pulse #x18)
(defvar audio_longest_pulse #x28)
(defvar frame_sync_width #x08)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar audio_average_pulse (+ audio_shortest_pulse (half audio_pulse_width)))

(load "bender/vic-20/cpu-cycles.lisp")
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

(defun make-audio (tv name file gain bass)
  (make-wav name file gain bass tv)
  (make-conversion name tv))

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-output-file in   in-file
                          out  out-file
    (tap2wav in out)))

(defun make (to files &optional (cmds nil))
  (apply #'assemble-files to files)
  (& cmds (make-vice-commands cmds "break .stop")))

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

(defun convert-splash-bit (x)
  (?
    (== x 0)  1
    (== x 1)  0
    x))

(defun convert-splash-byte-mc (out x)
  (let v 0
    (dotimes (i 4 (write-byte v out))
      (let s (* 2 i)
        (= v (+ v (<< (convert-splash-bit (>> (bit-and x (<< 3 s)) s)) s)))))))

(defun convert-splash-byte-sc (out x)
  (let v 0
    (dotimes (i 8 (write-byte v out))
      (= v (+ v (<< (convert-splash-bit (>> (bit-and x (<< 1 i)) i)) i))))))

(defun convert-splash-colors (out in screen colors)
  (dotimes (i 160)
    (let c (char-code (elt colors (position-if [== _ i] screen)))
      (dotimes (j 8)
        (? (zero? (bit-and c 8))
           (convert-splash-byte-sc out (read-byte in))
           (convert-splash-byte-mc out (read-byte in)))))))

(defun make-splash-gfx ()
  (make "obj/splash.chars.bin"
        '("splash/gfx-chars.asm"))
  (make "obj/splash.screen.bin"
        '("splash/gfx-screen.asm"))
  (make "obj/splash.colors.bin"
        '("splash/gfx-colors.asm")))
;  (with-input-file in "obj/splash.chars.bin"
;    (with-output-file out "obj/splash.chars.negated.bin"
;      (convert-splash-colors out in (fetch-file "obj/splash.screen.bin") (fetch-file "obj/splash.colors.bin")))))

(defun break-up-splash-chars ()
  (put-file "obj/splash.chars.0-127.bin" (subseq (fetch-file "obj/splash.chars.bin") 0 1024))
  (put-file "obj/splash.chars.128-159.bin" (subseq (fetch-file "obj/splash.chars.bin") 1024 (+ 1024 256))))

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

(defun make-8k (imported-labels)
  (with-temporary *imported-labels* imported-labels
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/8k." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "primary-loader/zeropage.asm"
              "expanded/8k.asm"
              "expanded/init-8k.asm"
              "expanded/patch-8k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/gfx-title.asm")
            (+ "obj/8k." ! ".prg.vice.txt")))))

(defun make-3k (imported-labels)
  (with-temporary *imported-labels* imported-labels
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/3k." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "primary-loader/zeropage.asm"
              "expanded/3k.asm"
              "expanded/init-3k.asm"
              "secondary-loader/start.asm"
              "expanded/patch-3k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/gfx-title.asm")
            (+ "obj/3k." ! ".prg.vice.txt")))))

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

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
        (make-8k imported-labels)
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
      (make-audio *tv* "theme1" "media/boray_no_syrup.mp3" "3" "-64")
      (make-audio *tv* "theme2" "media/theme-lukas.mp3" "3" "-72")
      (with-output-file o (+ "compiled/pulse." tv ".tap")
        (write-tap o
            (+ (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/loader." tv ".prg"))))
                           (+ (padded-name (+ "PULSE (" (upcase tv) ")"))
                              (fetch-file "obj/model-detection.bin"))
                           :start #x1001)
               (bin2pottap (string-list (fetch-file (+ "obj/3k." tv ".prg"))))
               (bin2pottap (string-list (fetch-file (+ "obj/8k." tv ".prg"))))
               (bin2pottap (string-list (fetch-file (+ "obj/splash.crunched." tv ".prg"))))
               (bin2pottap (string-list (glued-game-and-splash-gfx *current-game*)))))
;        (adotimes 256 (princ (code-char #x20) o))
        (wav2pwm o (+ "obj/theme1_downsampled_" tv ".wav") :pause-before 0)
        (wav2pwm o (+ "obj/theme2_downsampled_" tv ".wav")))
      (sb-ext:run-program "/usr/bin/zip"
                          (list (+ "compiled/pulse." tv ".tap.zip")
                                (+ "compiled/pulse." tv ".tap"))
                          :pty cl:*standard-output*))))

(defun tap-rate (tv avg-len)
  ; XXX Need INTEGER here because tré's FRACTION-CHARS is buggered.
  (integer (/ (? (eq tv :pal)
                 +cpu-cycles-pal+
                 +cpu-cycles-ntsc+)
              (* 8 avg-len))))

(defun check-end ()
  (& (< #x1e00 *pc*)
     *assign-blocks-to-segments?*
     (error "End of program exceeds $1e00 by ~A bytes." (- *pc* #x1e00))))

(make-model-detection)
(make-splash-gfx)
(break-up-splash-chars)

(with-temporary *tape-release?* t
  (make-all-games :pal))
(unless *only-pal-vic?*
  (with-temporary *tape-release?* t
    (make-all-games :ntsc))
  (make-game :prg "pulse.prg" "obj/pulse.vice.txt")
  (when *make-shadowvic-versions?*
    (with-temporary *virtual?* t
      (make-game :virtual "compiled/virtual.bin" "obj/virtual.vice.txt"))))

(print-pwm-info)

(alet (+ *pulse-short* (half (- *pulse-long* *pulse-short*)))
  (format t "Baud rates: ~A (NTSC), ~A (PAL)~%"
          (tap-rate :ntsc !) (tap-rate :pal !)))

(when *make-wav?*
  (format t "Making PAL WAV file...~%")
  (with-input-file i "compiled/pulse.pal.tap"
    (with-output-file o "compiled/pulse.pal.wav"
      (tap2wav i o 48000 (cpu-cycles :pal))))

  (format t "Making NTSC WAV file...~%")
  (with-input-file i "compiled/pulse.ntsc.tap"
    (with-output-file o "compiled/pulse.ntsc.wav"
      (tap2wav i o 48000 (cpu-cycles :ntsc)))))

(format t "Done making 'Pulse'. See directory 'compiled/'.~%")

(quit)
