numchars    = 128

chars       = $1000
charsize    = numchars * 8
bufsize     = charsize / 2
charmask    = numchars - 1
bankmask    = numchars / 2
screensize  = 22 * 23

scr         = $00
col         = $02
scrx        = $04
scry        = $05
curcol      = $66
spr         = $07
sprx        = $09
spry        = $0a
sprbits     = $0b
sprchar     = $0d
sprshiftx   = $0e
sprshifty   = $0f
spr_u       = $10
spr_l       = $11
sprbank     = $12
counter     = $13
counter_u   = $14
tmp         = $15
tmp2        = $16
tmp3        = $17

sprites_l   = $20
sprites_h   = $30
sprites_x   = $40
sprites_y   = $50
sprites_c   = $70
sprites_ox  = $80
sprites_oy  = $90
