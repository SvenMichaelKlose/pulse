(= *model* :vic-20)

(defconstant +versions+ '(:pal-tape :tape-wav))
;(defconstant +versions+ '(:free :free+8k :pal-tape :ntsc-tape :shadowvic :tape-wav))
(defvar *tape-wav-sine?* t) ; Much better audio but slow to build.

(defun make-version? (&rest x)
  (some [member _ +versions+] x))

(defvar *virtual?* nil)
(defvar *tape-release?* nil)
(defvar *free+8k?* nil)

(defvar *video?* nil) ; Nipkow player experimental foo.

(defvar *tv* nil)
(defvar *current-game* nil)

(defvar *ram-audio-rate* 2000)
(defvar *ram-audio-rate2* 3000)

(defvar *fastloader-rate* 3000)
(defvar *tape-wav-rate* 44100)

(load "bender/vic-20/vic.lisp")
(load "flight/tap.lisp")
(load "flight/scaling.lisp")
(load "nipkow/src/convert.lisp")
(load "read-screen-designer.lisp")

(defun delay-frames (x)
  (? (eq *tv* :pal)
     x
     (integer (/ (* x 60) 50))))

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

(defun make-primary-loader-tap (tv)
  (bin2cbmtap (cddr (string-list (fetch-file (+ "obj/loader." tv ".prg"))))
              (+ (padded-name (+ "PULSE (" (upcase tv) ")"))
                 (fetch-file "obj/model-detection.bin"))
              :start #x1001))

(defun make-tap ()
  (with (tv        (downcase (symbol-name *tv*))
         out-name  (+ "compiled/pulse." tv ".tap"))
    (with-output-file o out-name
      (write-tap o
          (+ (make-primary-loader-tap tv)
             (fastloader-block (fetch-file (+ "obj/eyes." tv ".prg")) :gap #x80000)
             (fastloader-block (fetch-file (+ "obj/3k.crunched." tv ".prg")) :gap #xc0000)
             (fastloader-block (fetch-file (+ "obj/message." tv ".prg")) :gap #x60000)
             (fastloader-block (fetch-file (+ "obj/sun." tv ".prg")) :gap #x80000)
             (fastloader-block (fetch-file (+ "obj/8k.crunched." tv ".prg")) :gap #x40000)
             (fastloader-block (fetch-file (+ "obj/flight.crunched." tv ".prg")) :gap #x80000)
             (fetch-file "obj/radio0.tap")
             (fastloader-block (fetch-file (+ "obj/splash.crunched." tv ".prg")) :gap #x10000)
             (fastloader-block (glued-game-and-splash-gfx *current-game*) :gap #x80000)
             (fetch-file (+ "obj/splash-audio." tv ".bin"))
             (fetch-file (+ "obj/splash-audio." tv ".bin")))))
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

(defun make-tapwav (tv)
  (when (make-version? :tape-wav)
    (format t "Making ~A tape WAV file...~%" (symbol-name *tv*))
    (alet (+ "compiled/pulse." tv)
      (with-io i (+ ! ".tap")
               o (+ ! ".wav")
        (tap2wav i o *tape-wav-rate* (cpu-cycles *tv*) :sine? *tape-wav-sine?*)))
    (make-zip-archive (+ "compiled/pulse." tv ".wav.zip")
                      (+ "compiled/pulse." tv ".wav"))))

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
        (make-16k "16k" !)
        (make-8k "8k" !)
        (make-flight)
        (make-sun)
        (make-message)
        (make-3k !)
        (make-eyes)
        (make-loader))
      (make-radio-wav *tv*)
      (nipkow-convert "theme-splash" "3" "-60" *tv* *nipkow-pulse-rate*)
      (with-io i (+ "obj/theme-splash.downsampled." tv ".wav")
               o (+ "obj/splash-audio." tv ".bin")
        (wav2pwm o i :pause-before 0 :skip-first #x600))
      (make-tap)
      (make-tapwav tv))))

(when (make-version? :free)
  (make-game :prg "compiled/pulse.prg" "obj/pulse.vice.txt"))

(when (make-version? :pal-tape :ntsc-tape :free+8k)
  (make-ram-audio "get_ready" "media/intermediate/get_ready.wav" "3" "-56")
  (make-ram-audio2 "intermediate" "media/intermediate/audio.wav" "12" "-64")
  (make-ram-audio2 "intermediate2" "media/intermediate/audio2.wav" "12" "-64"))

(awhen (make-version? :free+8k)
  (with-temporaries (*tv*        :pal
                     *model*     :vic-20+xk
                     *free+8k?*  t)
    (make-game ! "obj/game.8k.prg" "obj/game.8k.vice.txt")
    (exomize (+ "obj/game.8k.prg")
             (+ "obj/game.8k.crunched.prg")
             "1002" "20")
    (make-8k "free+8k" (get-labels))
    (make-free+8k)))

(when (make-version? :pal-tape :ntsc-tape)
  (make-model-detection)
  (nipkow-make-wav "theme-splash" "media/splash/theme-boray.mp3")
  (nipkow-make-wav "radio" "media/radio.ogg"))

(when (make-version? :pal-tape)
  (set-fastloader-rate :pal *fastloader-rate*)
  (make-all-games :pal))
(when (make-version? :ntsc-tape)
  (set-fastloader-rate :ntsc *fastloader-rate*)
  (make-all-games :ntsc))
(when (make-version? :shadowvic)
  (with-temporary *virtual?* t
    (make-game :virtual "compiled/virtual.bin" "obj/virtual.vice.txt")))

(format t "Done making 'Pulse'. See directory 'compiled/'.~%")
(quit)
