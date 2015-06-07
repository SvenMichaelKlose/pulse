(defun pulse-files (&optional (version nil))
  `("game.defs.asm"
    "zeropage.asm"

    ,@(? (eq version :virtual)
         '("no-loader.asm")
         '("../bender/vic-20/basic-loader.asm"))
    "../bender/vic-20/vic.asm"

    "init.asm"
      "intro.asm"

      "stackmem-start.asm"
        "random.asm"
        "score.asm"
        "explosion-colors.asm"
      "stackmem-end.asm"

      "lowmem-start.asm"
        "blitter.asm"
        "chars.asm"
        "screen.asm"
        "math.asm"
        "bullet.asm"
        "bits.asm"
        "gfx-sprites.asm"
        "level-patterns.asm"
      "lowmem-end.asm"
    "init-end.asm"

    "sinetab.asm"
    "tiles.asm"
    "gfx-tiles.asm"
    "sprite-inits.asm"
    "sprites.asm"
    ,@(? (eq version :virtual)
         '("sprites-virtual.asm")
         '("sprites-vic.asm"))
    "controllers.asm"
    "grenade.asm"
    "game-over.asm"
    "main-start.asm"
      "sniper.asm"
      "scout.asm"
    "main-end.asm"
    "foreground.asm"
    "level.asm"
    "level-data.asm"))
