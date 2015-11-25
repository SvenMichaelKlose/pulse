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

    "low-segments.asm"

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
    "game-over.asm"
    "main-start.asm"
      "sniper.asm"
      "scout.asm"
    "main-end.asm"
    "level-data.asm"
    "level-patterns.asm"
    "foreground.asm"
    "level.asm"
    ))
