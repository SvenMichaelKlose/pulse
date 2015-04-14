(defvar *loader-start* nil)

(apply #'assemble-files "pulse.prg"
      '("vic.defs.asm"
        "game.defs.asm"
        "zeropage.asm"

        "basic-loader.asm"

        "init.asm"
          "intro.asm"

          "stackmem-start.asm"
            "random.asm"
            "score.asm"
          "stackmem-end.asm"

          "lowmem-start.asm"
            "blitter.asm"
            "chars.asm"
            "screen.asm"
            "math.asm"
            "level-bullet.asm"
            "level-scout.asm"
            "level-sniper.asm"
          "lowmem-end.asm"
        "init-end.asm"

        "bits.asm"
        "gfx-sprites.asm"
        "gfx-tiles.asm"
        "tiles.asm"
        "level-data.asm"
        "level-patterns.asm"
        "sprites.asm"
        "controllers.asm"
        "grenade.asm"
        "main.asm"
        "foreground.asm"
        "level.asm"))
(make-vice-commands "vice.txt")
(quit)
