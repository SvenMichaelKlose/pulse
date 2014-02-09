numsprites  = 16
numchars    = 128

chars       = $1000
first_char  = 1
charsize    = numchars * 8
charmask    = numchars - 1
sprbufsize  = charsize / 2
sprbufmask  = numchars / 2
framechars  = numchars / 2

fire_interval = 5

s           = $00
d           = $02
c           = $04
scr         = $04
col         = $06
scrx        = $08
scry        = $09
curcol      = $0a
sprchar     = $0b
sprshiftxl  = $0c
sprshiftxr  = $0d
sprshifty   = $0e
spr_u       = $0f
spr_l       = $10
sprbank     = $11
counter_u   = $12
tmp         = $13
tmp2        = $14
framecounter = $15
random      = $16
counter     = $17

scroll      = $18
scrollchars = $19
leftmost_brick = $1a
bgchar      = $1b

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
