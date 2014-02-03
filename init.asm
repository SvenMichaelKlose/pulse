numchars    = 128

chars       = $1000
charsize    = numchars * 8
bufsize     = charsize / 2
charmask    = numchars - 1
realstart   = $1000 + charsize
reallen     = realend-realstart
end         = start+reallen
bankmask    = numchars / 2

screensize  = 22 * 23

rels     = end-1
reld     = realend-1

main:
    cli
    lda #$7f
    sta $912e     ; disable and acknowledge interrupts
    sta $912d
    sta $911e     ; disable NMIs (Restore key)

    lda #%11111100  ; Our charset.
    sta $9005
    lda #8+blue       ; Screen and border.
    sta $900f
    lda #red*16     ; Auxiliary color.
    sta $900e
    lda #<rels
    sta s
    lda #>rels
    sta s+1
    lda #<reld
    sta d
    lda #>reld
    sta d+1
    lda #<reallen
    sta c
    lda #>reallen
    sta c+1
.(
    ldy #0
l1: lda c
    bne l2
    lda c+1
    beq e1
    dec c+1
l2: dec c
    lda (s),y
    sta (d),y
    lda s
    bne l3
    dec s+1
l3: dec s
    lda d
    bne l4
    dec d+1
l4: dec d
    jmp l1
e1:
.)
    jmp realstart

s           = $00
d           = $02
c           = $04

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

start:
* = realstart
    jsr clear_screen

.(
    ldx #numchars-1
l1: txa
    sta screen+17*22,x
    dex
    bpl l1
.)

.(
    lda #0
    sta sprbank
    ldx #7
l1: sta chars,x
    dex
    bpl l1
.)

.(
    lda #0
    ldx #15
l1: sta sprites_ox,x
    sta sprites_oy,x
    dex
    bpl l1
.)

    lda #0
    sta tmp3

mainloop:
    inc tmp3
    lda tmp3
    sta tmp2
    lda #0
    sta tmp

.(
    ldx #0
l1: lda tmp
    sta sprites_x,x
    lda tmp2
    and #127
    sta tmp2
    sta sprites_y,x
    lda #<spr1
    sta sprites_l,x
    lda #>spr1
    sta sprites_h,x
    txa
    and #7
    sta sprites_c,x
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp2
    inc tmp2
    inc tmp2
    inx
    cpx #$0f
    bne l1
.)
    lda #0
    sta sprites_h,x

    jsr frame
;.(
;    lda #$13
;    sta $900f
;    ldx #20
;l1: dex
;    bne l1
;    lda #blue
;    sta $900f
;.)
    jmp mainloop

frame:
    lda sprbank
    ora #1
    sta sprchar

.(  
l1: lda $9004
    cmp #110 ;130
    bne l1
.)
;.(
;    lda #$17
;    sta $900f
;    ldx #20
;l1: dex
;    bne l1
;    lda #blue
;    sta $900f
;.)

.(
    ldx #0
loop:
    lda sprites_h,x
    beq n1
    sta spr+1
    txa
    pha
    lda sprites_l,x
    sta spr
    lda sprites_x,x
    sta sprx
    lda sprites_y,x
    sta spry
    lda sprites_c,x
    sta curcol
    jsr draw_sprite
    pla
    tax
    inx
    jmp loop
n1:
.)

    lda sprbank
    eor #bankmask
    sta sprbank

; Remove old sprite chars.
.(
    ldx #0
l1: lda sprites_h,x
    beq e1
    lda sprites_ox,x
    sta scrx
    lda sprites_oy,x
    sta scry
    jsr clear_old
    inc scrx
    jsr clear_old
    dec scrx
    inc scry
    jsr clear_old
    inc scrx
    jsr clear_old
    lda sprites_x,x
    clc
    lsr
    lsr
    lsr
    sta sprites_ox,x
    lda sprites_y,x
    clc
    lsr
    lsr
    lsr
    sta sprites_oy,x
    inx
    jmp l1
e1:
.)

    rts

clear_old:
.(
    jsr scraddr
    ldy #0
    lda (scr),y
    beq e1
    and #bankmask
    cmp sprbank
    bne e1
    lda #0
    sta (scr),y
    sta (col),y
e1: rts
.)

draw_sprite:
.(
    lda sprx        ; Get char position on screen.
    clc
    lsr
    lsr
    lsr
    sta scrx
    lda spry
    clc
    lsr
    lsr
    lsr
    sta scry

    lda sprx        ; Get leftovers for shifting.
    and #%111
    sta sprshiftx
    lda spry
    and #%111
    sta sprshifty

    lda spr
    sta spr_u

; Write upper left half of char.
    jsr get_spritechar
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda sprbits+1
    adc #0
    sta sprbits+1
    lda #8
    sec
    sbc sprshifty
    sta counter
    sta counter_u
    ldy #0
    jsr write_sprite_l
    ldx sprshifty
    beq n1

; Write lower half of char.
    inc scry            ; Prepare next line.
    jsr get_spritechar
    lda spr
    clc
    adc counter_u
    sta spr
    sta spr_l
    lda sprshifty
    sta counter
    ldy #0
    jsr write_sprite_l
    dec scry

n1:lda sprshiftx
    beq n2

; Make shift.
    lda #8
    sec
    sbc sprshiftx
    sta sprshiftx

; Write upper right
    inc scrx            ; Prepare next line.
    jsr get_spritechar
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda sprbits+1
    adc #0
    sta sprbits+1
    lda spr_u
    sta spr
    lda counter_u
    sta counter
    jsr write_sprite_r
    ldx sprshifty
    beq n2

; Write lower left
    inc scry
    jsr get_spritechar
    lda spr_l
    sta spr
    lda sprshifty
    sta counter
    jsr write_sprite_r

n2: rts
.)

write_sprite_l:
.(
l1: lda (spr),y
    ldx sprshiftx
s2: dex
    bmi s1
    lsr
    jmp s2
s1: ora (sprbits),y
    sta (sprbits),y
    iny
    dec counter
    bne l1
    rts
.)

write_sprite_r:
.(
l1: lda (spr),y
    ldx sprshiftx
s2: dex
    bmi s1
    asl
    jmp s2
s1: ora (sprbits),y
    sta (sprbits),y
    iny
    dec counter
    bne l1
    rts
.)

get_spritechar:
.(
    jsr scraddr
    ldy #0
    lda curcol
    sta (col),y
    lda (scr),y
    beq l2
    tax
    and #%01000000
    cmp sprbank
    bne l2
    txa
    jmp l1
l2: lda sprchar     ; Pick fresh one from top.
    and #%01111111
    inc sprchar
    sta (scr),y
    jsr l1
    ldy #7
    lda #0
l3: sta (sprbits),y
    dey
    bpl l3
    ldy #0
    rts

l1: clc
    rol             ; Get char address.
    adc #0
    rol
    adc #0
    rol
    adc #0
    tax
    and #%11111000
    sta sprbits
    txa
    and #%00000111
    ora #>chars
    sta sprbits+1
    rts
.)

scraddr:
    ldy scry
    lda line_offsets_l,y
    clc
    adc scrx
    sta scr
    sta col
    php
    lda #>screen
    adc line_offsets_h,y
    sta scr+1
    plp
    lda #>colors
    adc line_offsets_h,y
    sta col+1
    rts

clear_screen:
    lda #<screen
    sta d
    lda #>screen
    sta d+1
    lda #<screensize
    ldy #>screensize
    jsr bzero
    lda #<colors
    sta d
    lda #>colors
    sta d+1
    lda #<screensize
    ldy #>screensize
    jsr bzero
    rts

bzero:
.(
    sta c
    sty c+1
    ldy #0
l1: lda c
    bne l2
    lda c+1
    beq e1
    dec c+1
l2: dec c
w:  tya
    sta (d),y
    inc d
    bne l1
    inc d+1
    jmp l1
e1: rts
.)

    .byte %11111111
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %11111111

    .byte %11111111
    .byte %11111111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

spr1:
    .byte %01111111
    .byte %11111111
    .byte %11000000
    .byte %11000000
    .byte %11000000
    .byte %11000000
    .byte %11000000
    .byte %11000000

    .byte %11111110
    .byte %11111111
    .byte %00000011
    .byte %00000011
    .byte %00000011
    .byte %00000011
    .byte %00000011
    .byte %00000011

    .byte %11000000
    .byte %10000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

    .byte %00000011
    .byte %00000001
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

line_offsets_l:
    .byte 0, 22*1, 22*2, 22*3, 22*4, 22*5, 22*6, 22*7, 22*8, 22*9, 22*10, 22*11, <22*12, <22*13, <22*14, <22*15, <22*16, <22*17, <22*18, <22*19, <22*20, <22*21, <22*22
line_offsets_h:
    .byte >0, >22*1, >22*2, >22*3, >22*4, >22*5, >22*6, >22*7, >22*8, >22*9, >22*10, >22*11, >22*12, >22*13, >22*14, >22*15, >22*16, >22*17, >22*18, >22*19, >22*20, >22*21, >22*22
