numchars    = 128
numsprites  = 16
numbricks   = 32
charset     = $1000

charsetsize         = numchars * 8
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

framecounter            = $0b
framecounter_high       = $0c

next_sprite_char        = $0d
sprite_shift_y          = $0e
sprite_data_top         = $0f
sprite_data_bottom      = $10
sprite_height_top       = $11
spriteframe             = $12

scrolled_bits           = $13
scrolled_chars          = $14
leftmost_brick          = $15
free_bricks             = $16
next_foreground_char    = $17
foreground_collision    = $18

charsetmask             = $19
tmp                     = $1a
tmp2                    = $1b
tmp3                    = $1c
counter                 = $1d
repetition              = $1e

adding_scout            = $1f
adding_scout_delay      = $20
scout_formation_y       = $21
formation_left_unhit    = $22

level_pos               = $23
level_delay             = $24
level_old_y             = $25

fire_interval           = $26
has_double_laser        = $27
has_autofire            = $28
is_firing               = $29
is_invincible           = $2a
death_timer             = $2b
lifes                   = $2c
active_bricks           = $2d
bricklist_r             = $2e ; 8 bytes.

sound_start             = $36
sound_explosion         = $36
sound_laser             = $37
sound_bonus             = $38
sound_foreground        = $39
sound_dead              = $41
sound_end               = $41

sprites_x   = $50   ; X position.
sprites_y   = $60   ; Y position.
sprites_i   = $70   ; Flags.
sprites_c   = $80   ; Color.
sprites_l   = $90   ; Low character address.
sprites_fl  = $a0   ; Function controlling the sprite.
sprites_fh  = $b0   ; Function controlling the sprite.
sprites_d   = $c0   ; Whatever the controller wants.
sprites_ox  = $d0   ; Former X position for cleaning up.
sprites_oy  = $e0   ; Former Y position for cleaning up.

hiscore     = $f0

scrbricks_i = $100
scrbricks_x = $120
scrbricks_y = $140
scrbricks_n = $160

x0      = $f0                                                                   
y0      = $f1
x1      = $f2
y1      = $f3
dx      = $f4
dy      = $f5
line_d  = $f9
