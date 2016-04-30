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
        (in? version :tap :free+8k :free+16k) '("tape-loader.asm")
        '("../bender/vic-20/basic-loader.asm"))

    ,@(?
        (eq version :virtual)  '("init-virtual.asm")
        (eq version :tap)      '("init-tape-release.asm")
        '("init.asm"))

    ,@(unless (eq version :tap)
        '("intro.asm"))

    ,@(unless (in? version :virtual)
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
    ,@(when (in? version :virtual)
        '("virtual-repositioning.asm"))
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
        cmds)
  version)

(defun make-free+8k ()
  (make "compiled/pulse.8k.prg"
        '("bender/vic-20/vic.asm"
          "primary-loader/models.asm"
          "bender/vic-20/basic-loader.asm"
          "game/free+8k.asm")
        "compiled/pulse.8k.prg.vice.txt"))

(defun make-free+16k ()
  (make "compiled/pulse.16k.prg"
        '("bender/vic-20/vic.asm"
          "primary-loader/models.asm"
          "bender/vic-20/basic-loader.asm"
          "game/free+8k.asm")
        "compiled/pulse.16k.prg.vice.txt"))
