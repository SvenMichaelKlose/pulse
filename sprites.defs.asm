numchars    = 128
numsprites  = 16
numbricks   = 32
charset     = $1000

charsetsize         = numchars * 8
charsetmask         = numchars - 1
framesize           = charsetsize / 2
framemask           = numchars / 2
framechars          = numchars / 2

first_sprite_char   = 1

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
tmp3        = $1b
counter     = $1c
repetition  = $1d

foreground_collision = $1e
framecounter_high = $1f

sprites_x   = $30   ; X position.
sprites_y   = $40   ; Y position.
sprites_i   = $50   ; Whatever the function needs.
sprites_c   = $60   ; Color.
sprites_l   = $70   ; Low character address.
sprites_fl  = $80   ; Function controlling the sprite.
sprites_fh  = $90   ; Function controlling the sprite.
sprites_ox  = $a0   ; Former X position for cleaning up.
sprites_oy  = $b0   ; Former Y position for cleaning up.

scrbricks_i = $c0
scrbricks_x = $e0
scrbricks_y = $100
scrbricks_n = $120
