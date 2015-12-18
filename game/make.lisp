(defun tile-rc (x)
  (unless (first-pass?)
    (+ (>> (- (low (get-label x)) (low (get-label 'background))) 3)
       (get-label 'framemask)
       (get-label 'foreground))))

(defun check-zeropage-size ()
  (when (< #x100 *pc*)
    (error "Zero page overflow by ~A bytes." (- *pc* #x100))))

(defun check-end ()
  (& (< #x1e00 *pc*)
     *assign-blocks-to-segments?*
     (error "End of program exceeds $1e00 by ~A bytes." (- *pc* #x1e00))))

(defun pulse-files (&optional (version nil))
  `("../bender/vic-20/vic.asm"
    "game.defs.asm"
    "zeropage.asm"
    "../primary-loader/models.asm"

    ,@(?
        (eq version :virtual)  '("no-loader.asm")
        (eq version :tap)      '("tape-loader.asm")
        '("../bender/vic-20/basic-loader.asm"))

    ,@(? (eq version :virtual)
         '("init-virtual.asm")
         '("init.asm"))
    "intro.asm"

    ,@(unless (eq version :virtual)
        '("low-segments.asm"))

    "gfx-sprites.asm"
    "gfx-tiles.asm"
    "sprite-inits.asm"

    "high-segment.asm"

    "random.asm"
    "score.asm"
    "explosion-colors.asm"
    "blitter.asm"
    "chars.asm"
    "screen.asm"
    "math.asm"
    "bullet.asm"
    "bits.asm"
    "tiles.asm"
    "sinetab.asm"
    "sprites.asm"
    "sprites-vic.asm"
    "controllers.asm"
    "grenade.asm"

    "start.asm"
    "mainloop-start.asm"
      "sound.asm"
      "frame.asm"
      "sniper.asm"
      "scout.asm"
    "mainloop-end.asm"

    "level-data.asm"
    "level-patterns.asm"
    "foreground.asm"
    "level.asm"
    "check-end.asm"))

(defun make-game (version file cmds)
  (make file
        (@ [+ "game/" _] (pulse-files version))
        cmds))
