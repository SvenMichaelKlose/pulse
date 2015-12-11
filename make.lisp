(= *model* :vic-20)

(defconstant +versions+ '(:free :pal-tape :ntsc-tape :c64-master :shadowvic :wav))

(defun make-version? (&rest x)
  (some [member _ +versions+] x))

(defvar *virtual?* nil)
(defvar *video?* nil)
(defvar *tape-release?* nil)
(defvar *tv* nil)
(defvar *current-game* nil)

(defvar *bandwidth* 16)
(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *pulse-average* (+ *pulse-short* (half (- *pulse-long* *pulse-short*))))
(defvar *tape-pulse* (* 8 *pulse-average*))

(defvar audio_shortest_pulse #x18)
(defvar audio_longest_pulse #x28)
(defvar audio_pulse_width (- audio_longest_pulse audio_shortest_pulse))
(defvar audio_average_pulse (+ audio_shortest_pulse (half audio_pulse_width)))

(defvar *ram-audio-rate* 2000)
(defconstant +c64-pal-cycles+ 985248)

(load "bender/vic-20/cpu-cycles.lisp")
(load "secondary-loader/bin2pottap.lisp")
(load "radio/tap.lisp")
(load "nipkow/src/wav2pwm.lisp")
(load "game/files.lisp")

(defun tap-rate (tv)
  (integer (/ (? (eq tv :pal)
                 +cpu-cycles-pal+
                 +cpu-cycles-ntsc+)
              (* 8 *pulse-average*))))

(defun radio-rate (tv)
  (integer (/ (? (eq tv :pal)
                 +cpu-cycles-pal+
                 +cpu-cycles-ntsc+)
              (* 8 *radio-pulse-average*))))

(defun print-bitrate-info ()
  (format t "Fast loader rates:~% ~A Bd (NTSC)~% ~A Bd (PAL)~%"
            (tap-rate :ntsc) (tap-rate :pal))
  (print-pwm-info))

(defun tile-rc (x)
  (unless (first-pass?)
    (+ (>> (- (low (get-label x)) (low (get-label 'background))) 3)
       (get-label 'framemask)
       (get-label 'foreground))))

(defun check-zeropage-size ()
  (when (< #x100 *pc*)
    (error "Zero page overflow by ~A bytes." (- *pc* #x100))))

(defun make-wav (name file gain bass tv rate)
  (sb-ext:run-program "/usr/bin/mplayer"
    (list "-vo" "null" "-vc" "null" "-ao" (+ "pcm:fast:file=obj/" name "." (downcase (symbol-name tv)) ".wav") file)
    :pty cl:*standard-output*)
  (sb-ext:run-program "/usr/bin/sox"
    `(,(+ "obj/" name "." (downcase (symbol-name tv)) ".wav")
      ,(+ "obj/" name "." (downcase (symbol-name tv)) ".filtered.wav")
      ,@(& bass `("bass" ,bass))
      "lowpass" ,(princ (half rate) nil)
      ,@(& gain `("compand" "0.3,1" "6:-70,-60,-20" "-1" "-90" "0.2" "gain" ,gain)))
    :pty cl:*standard-output*))

(defun downsampled-audio-name (name tv)
  (+ "obj/" name ".downsampled." (downcase (symbol-name tv)) ".wav"))

(defun make-conversion (name tv rate)
  (sb-ext:run-program "/usr/bin/sox"
    (list (+ "obj/" name "." (downcase (symbol-name tv)) ".filtered.wav")
          "-c" "1"
          "-b" "16"
          "-r" (princ rate nil)
          (downsampled-audio-name name tv))
    :pty cl:*standard-output*))

(defun make-tape-audio (tv name file gain bass)
  (make-wav name file gain bass tv (pwm-pulse-rate tv))
  (make-conversion name tv (pwm-pulse-rate tv)))

(defun make-pwm (out in)
  (adotimes 44
    (read-byte in))
  (with (i nil
         b 0)
    (awhile (read-word in)
            nil
      (let v (integer (+ 8 (>> ! 12)))
        (? i
           (= b v)
           (write-byte (byte (+ b (<< v 4))) out)))
      (= i (toggle i)))))

(defun convert-to-pwm (in-name out-name)
  (with-input-file in in-name
    (with-output-file out out-name
      (make-pwm out in))))

(defun make-ram-audio (name file gain bass)
  (make-wav name file gain bass :ram *ram-audio-rate*)
  (make-conversion name :ram *ram-audio-rate*)
  (convert-to-pwm "obj/get_ready.downsampled.ram.wav"
                  "obj/get_ready.pwm"))

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-output-file in   in-file
                          out  out-file
    (tap2wav in out)))

(defun make-radio-wav (tv)
  (format t "Making radio…~%")
  (make-wav "radio" "media/radio.ogg" "3" "0" tv (half (pwm-pulse-rate tv)))
  (make-conversion "radio" tv (half (pwm-pulse-rate tv)))
  (with-output-file out "obj/radio.tap"
    (alet (downcase (symbol-name tv))
      (with-input-file in-wav (+ "obj/radio.downsampled." ! ".wav")
        (with-input-file in-bin (+ "obj/8k.crunched." ! ".prg")
          (radio2tap out in-wav in-bin))))))

(defun exomize (from to addr target)
  (sb-ext:run-program "/usr/local/bin/exomizer"
                      `("sfx" ,(+ "$" addr)
                        "-t" ,target
                        "-n"
                        ,(+ "-Di_load_addr=$" addr)
                        "-o" ,to
                        ,from)
                      :pty cl:*standard-output*))

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

(defun make-splash-gfx ()
  (make "obj/splash.chars.bin"
        '("splash/gfx-chars.asm"))
  (make "obj/splash.screen.bin"
        '("splash/gfx-screen.asm"))
  (make "obj/splash.colors.bin"
        '("splash/gfx-colors.asm")))

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
          (+ "obj/splash." ! ".prg.vice.txt"))
    (exomize (+ "obj/splash." ! ".prg")
             (+ "obj/splash.crunched." ! ".prg")
             "1002" "20")))

(defvar *have-ram-audio-player?* nil)

(defun make-8k (imported-labels)
  (with-temporaries(*imported-labels* imported-labels
                    *have-ram-audio-player?* t)
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/8k." ! ".prg")
            '(;"bender/vic-20/vic.asm"
              "expanded/init-8k.asm"
              "expanded/patch-8k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/gfx-title.asm"
              "expanded/ram-audio-player.asm")
            (+ "obj/8k." ! ".prg.vice.txt"))
      (exomize (+ "obj/8k." ! ".prg")
               (+ "obj/8k.crunched." ! ".prg")
               "2002" "52"))))

(defun make-3k (imported-labels)
  (with-temporary *imported-labels* imported-labels
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/patch-3k." ! ".bin")
            '(;"bender/vic-20/vic.asm"
              "expanded/patch-3k.asm"
              "expanded/sprites-vic-preshifted.asm"
              "expanded/title.asm"
              "expanded/gfx-title.asm")
            (+ "obj/patch-3k." ! ".bin.vice.txt"))
      (make (+ "obj/3k." ! ".prg")
            '(;"bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "radio/zeropage.asm"
              "expanded/init-3k.asm"
              "radio/loader.asm"
              "radio/flight.asm"
              "secondary-loader/start.asm")
            (+ "obj/3k." ! ".prg.vice.txt"))
      (exomize (+ "obj/3k." ! ".prg")
               (+ "obj/3k.crunched." ! ".prg")
               "1002" "20"))))

(defun make-eyes ()
  (with-temporary *imported-labels* nil
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/intro." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "primary-loader/zeropage.asm"
              "radio/intro.asm"
              "game/random.asm"
              "game/high-segment.asm"
              "secondary-loader/start.asm")
            (+ "obj/3k." ! ".prg.vice.txt")))))

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

(defun make-loaders (tv imported-labels)
  (with-temporary *imported-labels* imported-labels
    (make-splash-prg)
    (with (splash-size  (- (get-label 'relocated_splash_end)
                           (get-label 'relocated_splash)))
      (alet (get-label 'memory_end)
        (make-8k imported-labels)
        (make-3k imported-labels)
;        (make-eyes)
        (make-loader-prg)
        (values splash-size !)))))

(defun check-end ()
  (& (< #x1e00 *pc*)
     *assign-blocks-to-segments?*
     (error "End of program exceeds $1e00 by ~A bytes." (- *pc* #x1e00))))

(defun make-zip-archive (archive input-file)
  (sb-ext:run-program "/usr/bin/zip"
                      (list archive input-file)
                      :pty cl:*standard-output*))

(defun make-tap (c64-master?)
  (with (tv        (downcase (symbol-name *tv*))
         out-name  (+ "compiled/pulse." tv (? c64-master? ".c64-master" "") ".tap"))
    (with-output-file o out-name
      (write-tap o
          (+ (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/loader." tv ".prg"))))
                         (+ (padded-name (+ "PULSE (" (upcase tv) ")"))
                            (fetch-file "obj/model-detection.bin"))
                         :start #x1001)
;             (bin2pottap (string-list (fetch-file (+ "obj/intro." tv ".prg"))))
             (bin2pottap (string-list (fetch-file (+ "obj/3k.crunched." tv ".prg"))))
             (fetch-file "obj/radio.tap")
;             (bin2pottap (string-list (fetch-file (+ "obj/8k.crunched." tv ".prg"))))
             (bin2pottap (string-list (fetch-file (+ "obj/splash.crunched." tv ".prg"))))
             (bin2pottap (string-list (glued-game-and-splash-gfx *current-game*)))
             (fetch-file (+ "obj/splash-audio." tv ".bin")))
          :original-cycles (& c64-master? (cpu-cycles *tv*))
          :converted-cycles (& c64-master? +c64-pal-cycles+)))
    (make-zip-archive (+ out-name ".zip") out-name)))

(defun make-all-games (tv-standard)
  (with-temporaries (*tv* tv-standard
                     *tape-release?* t)
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
            (= *tape-loader-start* (- memory-end (- (get-label 'loader_end)
                                                    (get-label 'tape_loader))))
            (= *splash-start* (- *tape-loader-start* splash-size))))
        (make-loaders tv game-labels))
      (make-radio-wav *tv*)
      (make-tape-audio *tv* "theme-splash" "media/splash/theme-boray.mp3" "3" "-48")
      (make-tape-audio *tv* "theme-hiscore" "media/theme-lukas.mp3" "3" "-72")
      (with-output-file o (+ "obj/splash-audio." tv ".bin")
        (wav2pwm o (fetch-file (+ "obj/theme-splash.downsampled." tv ".wav")) :pause-before 0))
      (make-tap nil)
      (when (make-version? :wav)
        (format t "Making ~A WAV file...~%" (symbol-name *tv*))
        (with-input-file i (+ "compiled/pulse." tv ".tap")
          (with-output-file o (+ "compiled/pulse." tv ".wav")
            (tap2wav i o 48000 (cpu-cycles *tv*)))
            (make-zip-archive (+ "compiled/pulse." tv ".wav.zip")
                              (+ "compiled/pulse." tv ".wav")))))))

(when (make-version? :free)
  (make-game :prg "compiled/pulse.prg" "obj/pulse.vice.txt"))
(when (make-version? :pal-tape :ntsc-tape)
  (make-model-detection)
  (make-splash-gfx)
  (break-up-splash-chars)
  (make-ram-audio "get_ready" "media/intermediate/get_ready.wav" "3" "-64"))
(when (make-version? :pal-tape)
  (make-all-games :pal))
(when (make-version? :ntsc-tape)
  (make-all-games :ntsc))
(when (make-version? :c64-master)
  (with-temporary *tv* :pal
    (format t "Making master with C64 timing…~%")
    (make-tap t)))
(when (make-version? :shadowvic)
  (with-temporary *virtual?* t
    (make-game :virtual "compiled/virtual.bin" "obj/virtual.vice.txt")))
(print-bitrate-info)
(format t "Done making 'Pulse'. See directory 'compiled/'.~%")
(quit)
