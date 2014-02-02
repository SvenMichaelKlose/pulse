numchars    = 32

s           = $14
d           = $2b
c           = $2d

chars       = $1000
charsize    = numchars * 8
charmask    = charsize-1
realstart   = $1000 + charsize
reallen     = realend-realstart
end         = start+reallen

screensize  = 22 * 23

rels     = end-1
reld     = realend-1

main:
    cli
    lda #$7f
    sta $912e     ; disable and acknowledge interrupts
    sta $912d
    sta $911e     ; disable NMIs (Restore key)

    ; Upcase/downcase chars
    lda #%11111100
    sta $9005
    ; Screen and border to black.
    lda #$10
    sta $900f
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

scr         = $2f
spr         = $31
scrx        = $33
scry        = $34
sprbits     = $37
sprchar     = $43
col         = $61
curcol      = $63
sprlines    = $64
sprx        = $65
spry        = $66
tmp         = $67
tmp2        = $68
tmp3        = $69
counter     = $6b
counter_u   = $6c
counter_l   = $6d
tmp4        = $6e
sprshiftx   = $6f
sprshifty   = $70
sprbits_u   = $71
spr_u       = $72
spr_l       = $73

start:
* = realstart
    jsr clear_screen

    lda #<spr1
    sta spr
    lda #>spr1
    sta spr+1
    lda #4
    sta sprx
    lda #4
    sta spry
    lda #cyan
    sta curcol

start_sprites:
    lda #1
    sta sprchar

; Clear characters,
    lda #<chars
    sta d
    lda #>chars
    sta d+1
    lda #<charsize
    ldy #>charsize
    jsr bzero

; Get character address to write to.
.(
    lda sprx
    lsr
    lsr
    lsr
    sta scrx
    lda spry
    lsr
    lsr
    lsr
    sta scry

    lda spr
    sta spr_u

; Write upper left half of char.
    jsr get_spritechar

    lda sprx
    and #%111
    sta sprshiftx
    sta tmp3

    lda spry
    and #%111
    sta sprshifty
    clc
    adc sprbits
    sta sprbits
    sta sprbits_u
    sta tmp2
    lda #8
    sec
    sbc sprshifty
    sta tmp
    sta counter
    sta counter_u

    ldy #0
    jsr write_sprite

    ldx sprshifty
    beq n1

; Write lower half of char.
    sty tmp             ; Save pointer to sprite data.
    lda tmp3            ; Init X shift.
    sta sprshiftx
    inc scry            ; Prepare next line.
    jsr get_spritechar
    lda spr
    sta tmp4
    clc
    adc sprshifty
    sta spr
    sta spr_l
    lda #8
    sec
    sbc tmp
    sta counter
    sta counter_l
    jsr write_sprite

n1:lda sprshiftx
    beq n2

; Make shift.
    lda #8
    sec
    sbc sprshiftx
    sta sprshiftx

; Write upper right
    dec scry
    inc scrx            ; Prepare next line.
    jsr get_spritechar
    lda spr_u
    sta spr
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda counter_u
    sta counter
    ldy #0
    jsr write_sprite_r

    ldx sprshifty
    beq n2

; Write lower left
    inc scry
    jsr get_spritechar
    lda spr_l
    sta spr
    lda counter_l
    sta counter
    ldy #0
    jsr write_sprite_r

n2:
.)

block:
    jmp block

write_sprite:
.(
l1: lda (spr),y
    ldx sprshiftx
s2: dex
    bmi s1
    lsr
    jmp s2
s1: sta (sprbits),y
    iny
    dec counter
    bpl l1
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
s1: sta (sprbits),y
    iny
    dec counter
    bpl l1
    rts
.)

get_spritechar:
.(
    jsr scraddr
    ldy #0
    lda curcol
    sta (col),y
    lda (scr),y
    bne l1          ; Reuse existing character.
    lda sprchar     ; Pick fresh one from top.
    and #charmask
    inc sprchar
    sta (scr),y
l1: rol             ; Get char address.
    rol
    rol
    tax
    and #%11111000
    sta sprbits
    txa
    and #%00000111
    ora #>chars
    sta sprbits+1
    rts
.)

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

spr1:
    .byte %11111111
    .byte %10000001
    .byte %10000001
    .byte %11111111
    .byte %11111111
    .byte %00011000
    .byte %00011000
    .byte %11111111

line_offsets_l:
    .byte 0, 22*1, 22*2, 22*3, 22*4, 22*5, 22*6, 22*7, 22*8, 22*9, 22*10, 22*11, <22*12, <22*13, <22*14, <22*15, <22*16, <22*17, <22*18, <22*19, <22*20, <22*21, <22*22
line_offsets_h:
    .byte >0, >22*1, >22*2, >22*3, >22*4, >22*5, >22*6, >22*7, >22*8, >22*9, >22*10, >22*11, >22*12, >22*13, >22*14, >22*15, >22*16, >22*17, >22*18, >22*19, >22*20, >22*21, >22*22
