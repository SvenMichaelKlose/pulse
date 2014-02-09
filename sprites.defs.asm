numsprites  = 16
numchars    = 128

chars       = $1000
first_char  = 1
charsize    = numchars * 8
charmask    = numchars - 1
sprbufsize  = charsize / 2
sprbufmask  = numchars / 2

scr         = $04
col         = $06
scrx        = $08
scry        = $09
curcol      = $0a
spr         = $0b
sprchar     = $0d
sprshiftxl  = $0e
sprshiftxr  = $0f
sprshifty   = $10
spr_u       = $11
spr_l       = $12
sprbank     = $13
counter_u   = $14
tmp         = $15
tmp2        = $16
tmp3        = $17
framecounter = $18
random      = $19
counter     = $1a

scroll      = $1b
scrollchars = $1c
leftmost_brick = $1d

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
