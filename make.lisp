(= *model* :vic-20)

(defconstant +versions+ '(:pal-tape))
;(defconstant +versions+ '(:free :pal-tape :ntsc-tape :shadowvic :tape-wav)) ;:c64-master 

(defun make-version? (&rest x)
  (some [member _ +versions+] x))

(defvar *virtual?* nil)
(defvar *video?* nil)
(defvar *tape-release?* nil)
(defvar *tv* nil)
(defvar *current-game* nil)

(defvar *pulse-short* #x20)
(defvar *pulse-long* #x30)
(defvar *pulse-average* (+ *pulse-short* (half (- *pulse-long* *pulse-short*))))
(defvar *tape-pulse* (* 8 *pulse-average*))

(defvar *ram-audio-rate* 2000)
(defvar *ram-audio-rate2* 3000)
(defconstant +c64-pal-cycles+ 985248)

(defvar *tape-wav-rate* 41100)

(load "bender/vic-20/vic.lisp")
(load "bender/vic-20/cpu-cycles.lisp")
(load "flight/tap.lisp")
(load "flight/scaling.lisp")
(load "nipkow/src/convert.lisp")
(load "nipkow/src/wav2pwm.lisp")
(load "read-screen-designer.lisp")

(defun make-tape-wav (in-file out-file)
  (format t "Making tape WAV '~A' of '~A'...~%" out-file in-file)
  (with-input-output-file in   in-file
                          out  out-file
    (tap2wav in out)))

(defun exomize (from to addr target)
  (sb-ext:run-program "/usr/local/bin/exomizer"
                      `("sfx" ,(+ "$" addr)
                        "-t" ,target
                        "-n"
                        ,(+ "-Di_load_addr=$" addr)
                        "-o" ,to
                        ,from)
                      :pty cl:*standard-output*))

(defun make-zip-archive (archive input-file)
  (sb-ext:run-program "/usr/bin/zip"
                      (list archive input-file)
                      :pty cl:*standard-output*))

(defun make (to files &optional (cmds nil))
  (apply #'assemble-files to files)
  (& cmds (make-vice-commands cmds "break .stop")))

(defvar *splash-start* #x1234)
(defvar *tape-loader-start* #x1234)

(load "game/make.lisp")
(load "splash/make.lisp")
(load "flight/make.lisp")
(load "sun/make.lisp")
(load "message/make.lisp")
(load "expanded/make.lisp")
(load "eyes/make.lisp")
(load "secondary-loader/make.lisp")
(load "primary-loader/make.lisp")

(defun padded-name (x)
  (list-string (+ (string-list x) (maptimes [identity #\ ] (- 16 (length x))))))

(defun make-tap (c64-master?)
  (with (tv        (downcase (symbol-name *tv*))
         out-name  (+ "compiled/pulse." tv (? c64-master? ".c64-master" "") ".tap"))
    (with-output-file o out-name
      (write-tap o
          (+ (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/loader." tv ".prg"))))
                         (+ (padded-name (+ "PULSE (" (upcase tv) ")"))
                            (fetch-file "obj/model-detection.bin"))
                         :start #x1001)
             (fastloader-block (fetch-file (+ "obj/eyes." tv ".prg")))
             (fastloader-block (fetch-file (+ "obj/3k.crunched." tv ".prg")) :gap #x0c0000)
             (fastloader-block (fetch-file (+ "obj/message." tv ".prg")))
             (fastloader-block (fetch-file (+ "obj/sun." tv ".prg")))
             (fastloader-block (fetch-file (+ "obj/8k.crunched." tv ".prg")))
             (fastloader-block (fetch-file (+ "obj/flight.crunched." tv ".prg")) :gap #xc0000)
             (fetch-file "obj/radio0.tap")
             (fastloader-block (fetch-file (+ "obj/splash.crunched." tv ".prg")))
             (fastloader-block (glued-game-and-splash-gfx *current-game*))
             (fetch-file (+ "obj/splash-audio." tv ".bin")))
          :original-cycles (& c64-master? (cpu-cycles *tv*))
          :converted-cycles (& c64-master? +c64-pal-cycles+)))
    (make-zip-archive (+ out-name ".zip") out-name)))

(defun get-loader-address (imported-labels)
  (make-dummy-loader)
  (let loader-size (- (get-label 'loader_end)
                      (get-label 'tape_loader))
    (with-temporary *imported-labels* imported-labels
      (make-splash)
      (with (splash-size  (- (get-label 'relocated_splash_end)
                             (get-label 'relocated_splash)))
        (= *tape-loader-start* (- (get-label 'memory_end) loader-size))
        (= *splash-start* (- *tape-loader-start* splash-size))))))

(defun make-all-games (tv-standard)
  (with-temporaries (*tv* tv-standard
                     *tape-release?* t)
    (let tv (downcase (symbol-name *tv*))
      (= *current-game* (+ "obj/game.crunched." tv ".prg"))
      (make-game :tap
                 (+ "obj/game." tv ".prg")
                 (+ "obj/game." tv ".vice.txt"))
      (format t "Compressing game with exomizer...~%")
      (exomize (+ "obj/game." tv ".prg") (+ "obj/game.crunched." tv ".prg") "1002" "20")
      (alet (get-labels)
        (when (== *splash-start* #x1234)
          (get-loader-address !))
        (make-splash)
        (make-8k !)
        (make-flight)
        (make-sun)
        (make-message)
        (make-3k !)
        (make-eyes)
        (make-loader))
      (make-radio-wav *tv*)
      (make-tape-audio *tv* "theme-splash" "2" "-64")
      (with-input-file i (+ "obj/theme-splash.downsampled." tv ".wav")
        (with-output-file o (+ "obj/splash-audio." tv ".bin")
          (wav2pwm o i :pause-before 0)))
      (make-tap nil)
      (when (make-version? :tape-wav)
        (format t "Making ~A tape WAV file...~%" (symbol-name *tv*))
        (with-input-file i (+ "compiled/pulse." tv ".tap")
          (with-output-file o (+ "compiled/pulse." tv ".wav")
            (tap2wav i o *tape-wav-rate* (cpu-cycles *tv*)))
            (make-zip-archive (+ "compiled/pulse." tv ".wav.zip")
                              (+ "compiled/pulse." tv ".wav")))))))

(when (make-version? :free)
  (make-game :prg "compiled/pulse.prg" "obj/pulse.vice.txt"))
(when (make-version? :pal-tape :ntsc-tape)
  (make-model-detection)
  (make-ram-audio "get_ready" "media/intermediate/get_ready.wav" "3" "-56")
  (make-ram-audio2 "intermediate" "media/intermediate/audio.wav" "12" "-64")
  (make-ram-audio2 "intermediate2" "media/intermediate/audio2.wav" "12" "-64")
;  (with-temporary *ram-audio-rate* 4000
;    (make-ram-audio "theme-hiscore" "media/intermediate/audio.wav" "8" "-72"))
  (make-wav "theme-splash" "media/splash/theme-boray.mp3")
  (make-wav "radio" "media/radio.ogg"))
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
