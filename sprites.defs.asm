numchars    = 128
numsprites  = 16
numbricks   = 16
charset     = $1000

charsetsize         = numchars * 8
charsetmask         = numchars - 1
framesize           = charsetsize / 2
framemask           = numchars / 2
framechars          = numchars / 2

first_sprite_char   = 1
fire_interval       = 5

foreground          = framechars / 2 + framechars / 4

s                   = $00
d                   = $02
c                   = $04
scr                 = $04
col                 = $06
scrx                = $08
scry                = $09
curcol              = $0a

blitter_shift_left  = $0b
blitter_shift_right = $0c

framecounter        = $0d

next_sprite_char    = $0e
sprite_shift_y      = $0f
sprite_data_top     = $10
sprite_data_bottom  = $11
sprite_height_top   = $12
spriteframe         = $13

scrolled_bits       = $14
scrolled_chars      = $15
leftmost_brick      = $16
next_foreground_char = $17

random      = $18
tmp         = $19
tmp2        = $1a
counter     = $1b

sprites_l   = $20   ; Low character address.
sprites_h   = $30   ; High character address.
sprites_x   = $40   ; X position.
sprites_y   = $50   ; Y position.
sprites_c   = $60   ; Color.
sprites_ox  = $70   ; Former X position for cleaning up.
sprites_oy  = $80   ; Former Y position for cleaning up.
sprites_fh  = $90   ; Function controlling the sprite.
sprites_fl  = $a0   ; Function controlling the sprite.
sprites_i   = $b0   ; Whatever the function needs.

;bricks_x    = $c0
;bricks_y    = $d0
;bricks_c    = $e0
;bricks_l    = $f0
;bricks_m    = $100
;bricks_r    = $110
