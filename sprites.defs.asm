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
framecounter_high   = $0e

next_sprite_char    = $0f
sprite_shift_y      = $10
sprite_data_top     = $11
sprite_data_bottom  = $12
sprite_height_top   = $13
spriteframe         = $14

scrolled_bits       = $15
scrolled_chars      = $16
leftmost_brick      = $17
free_bricks         = $18
next_foreground_char = $19

random      = $1a
tmp         = $1b
tmp2        = $1c
tmp3        = $1d
counter     = $1e
repetition  = $1f

foreground_collision = $20
lifes       = $21

adding_scout            = $22
adding_scout_delay      = $23
scout_formation_y       = $24
formation_left_unhit    = $25

fire_interval           = $26
has_double_laser        = $27
has_autofire            = $28
is_firing               = $29
is_invincible           = $2a
level_pos               = $2b
level_delay             = $2c
level_old_y             = $2d

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
