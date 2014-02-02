numchars    = 32

s           = $14
d           = $2b
c           = $2d

chars       = $1000
charsize    = numchars * 8
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
    lda #$00
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

start:
* = realstart
    jsr clear_chars
    jsr clear_screen

    lda #0
    sta scrx
    sta scry
    lda #cyan
    sta curcol

start_sprites:
    lda #1
    sta sprchar

; Get character address to write to.
.(
    jsr scraddr
    ldy #0
    lda curcol
    sta (col),y

    lda (scr),y
    bne l1          ; Reuse existing character.
    lda sprchar     ; Pick fresh one from top.
    inc sprchar
    sta (scr),y
l1: rol
    rol
    rol
    tax
    and #%11111000
    sta sprbits
    txa
    and #%00000111
    ora #>chars
    sta sprbits+1
.)

    lda #<spr1
    sta spr
    lda #>spr1
    sta spr+1
.(
    ldy #7
l1: lda (spr),y
    sta (sprbits),y
    dey
    bpl l1
.)

block:
    jmp block

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

clear_chars:
    lda #<chars
    sta d
    lda #>chars
    sta d+1
    lda #<charsize
    ldy #>charsize
    jsr bzero
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
