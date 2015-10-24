(defun pulse-files (&optional (version nil))
  `("../bender/vic-20/vic.asm"
    "game.defs.asm"
    "zeropage.asm"

    ,@(?
        (eq version :virtual)  '("no-loader.asm")
        (eq version :tap)      '("tape-loader.asm")
        '("../bender/vic-20/basic-loader.asm"))

    ,@(? (eq version :virtual)
         '("init-virtual.asm")
         '("init.asm"))

    "intro.asm"

    ,@(unless (eq version :virtual)
        '("stackmem-start.asm"))
    "random.asm"
    "score.asm"
    "explosion-colors.asm"
    ,@(unless (eq version :virtual)
        '("stackmem-end.asm"))

    ,@(unless (eq version :virtual)
        '("lowmem-start.asm"))
    "blitter.asm"
    "chars.asm"
    "screen.asm"
    "math.asm"
    "bullet.asm"
    "bits.asm"
    "gfx-sprites.asm"
    "level-patterns.asm"
    ,@(unless (eq version :virtual)
        '("lowmem-end.asm"
          "init-end.asm"))

    "level-data.asm"
    "gfx-tiles.asm"
    "tiles.asm"
    "sinetab.asm"
    "sprite-inits.asm"
    "sprites.asm"
    "sprites-vic.asm"
    "controllers.asm"
    "grenade.asm"
    ,@(? nil ;*coinop?*
         '("coin.asm"))
    "game-over.asm"
    "main-start.asm"
      "sniper.asm"
      "scout.asm"
    "main-end.asm"
    "foreground.asm"
    "level.asm"))
