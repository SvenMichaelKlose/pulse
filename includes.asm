/*
#define STATIC
#define TIMING
#define SHOW_CHARSET
#define INVINCIBLE
*/

#include "game.defs.asm"
#include "zeropage.asm"
#include "kernal.asm"

#include "basic-loader.asm"

#include "init.asm"
#include "stackmem-start.asm"
#include "random.asm"
#include "score.asm"
#include "stackmem-end.asm"
#include "lowmem-start.asm"
#include "level-stars.asm"
#include "level-scout.asm"
#include "blitter.asm"
#include "chars.asm"
#include "screen.asm"
#include "bricks.asm"
#include "math.asm"
#include "lowmem-end.asm"
#include "intro.asm"
#include "bresenham.asm"
#include "init-end.asm"

#include "main.asm"
#include "level.asm"
#include "controllers.asm"
#include "level-bullet.asm"
#include "level-sniper.asm"
#include "sprites.asm"
#include "foreground.asm"
#include "gfx-sprites.asm"
#include "gfx-foreground.asm"
#include "bits.asm"
#include "end.asm"
