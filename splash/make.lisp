(defvar *bandwidth* 16)

(defvar *nipkow-pulse-rate* 5000)

(defconstant *splash-chars-0-127* nil)
(defconstant *splash-chars-128-159* nil)
(defconstant *splash-screen* nil)
(defconstant *splash-colours* nil)
(when (make-version? :pal-tape :ntsc-tape)
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    (= *splash-chars-0-127* (subseq chars. 0 1024))
    (= *splash-chars-128-159* (subseq chars. 1024 (+ 1024 256)))
    (= *splash-screen* screen.)
    (= *splash-colours* colours.)))

(defun glued-game-and-splash-gfx (game)
  (+ (subseq (fetch-file game) 0 1024)
     *splash-chars-128-159*
     (subseq (fetch-file game) (+ 1024 256))))

(defun make-splash ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/splash." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/models.asm"
            "primary-loader/zeropage.asm"
            "splash/main.asm"
            "secondary-loader/start.asm"
            "splash/splash.asm"
            "splash/audio-player.asm"
            "splash/start-game.asm")
          (+ "obj/splash." ! ".prg.vice.txt"))
    (exomize (+ "obj/splash." ! ".prg")
             (+ "obj/splash.crunched." ! ".prg")
             "1002" "20"
             :path *exomizer*)))
