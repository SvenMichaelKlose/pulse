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

s                       = $00
d                       = $02
c                       = $04
scr                     = $04
col                     = $06
scrx                    = $08
scry                    = $09
curcol                  = $0a

sl                      = $04
sm                      = $06
sr                      = $08

blitter_shift_left      = $0b
blitter_shift_right     = $0c

framecounter            = $0d
framecounter_high       = $0e

next_sprite_char        = $0f
sprite_shift_y          = $10
sprite_data_top         = $11
sprite_data_bottom      = $12
sprite_height_top       = $13
spriteframe             = $14

scrolled_bits           = $15
scrolled_chars          = $16
leftmost_brick          = $17
free_bricks             = $18
next_foreground_char    = $19
foreground_collision    = $1a

random                  = $1b
tmp                     = $1c
tmp2                    = $1d
tmp3                    = $1e
counter                 = $1f
repetition              = $20

adding_scout            = $21
adding_scout_delay      = $22
scout_formation_y       = $23
formation_left_unhit    = $24

level_pos               = $25
level_delay             = $26
level_old_y             = $27

fire_interval           = $28
has_double_laser        = $29
has_autofire            = $2a
is_firing               = $2b
is_invincible           = $2c
death_timer             = $2d
lifes                   = $2e
active_bricks           = $2f

sprites_x   = $30   ; X position.
sprites_y   = $40   ; Y position.
sprites_i   = $50   ; Flags.
sprites_c   = $60   ; Color.
sprites_l   = $70   ; Low character address.
sprites_fl  = $80   ; Function controlling the sprite.
sprites_fh  = $90   ; Function controlling the sprite.
sprites_d   = $a0   ; Whatever the controller wants.
sprites_ox  = $b0   ; Former X position for cleaning up.
sprites_oy  = $c0   ; Former Y position for cleaning up.

scrbricks_i = $100
scrbricks_x = $120
scrbricks_y = $140
scrbricks_n = $160
