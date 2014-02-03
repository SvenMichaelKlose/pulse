frame:
    ; Switch to the unused buffer,
.(  
    lda sprbank
    eor #bankmask
    sta sprbank
    bne l1
    ora #1
l1: sta sprchar
.)

    ; Wait until raster beam leaves the bitmap area.
.(  
l1: lda $9004
    cmp #130
    bne l1
.)

    ; Draw all sprites in the sprite table.
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

    ; Remove leftover chars.
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

; Remove char if it's not in the current bank.
clear_old:
.(
    jsr scraddr
    ldy #0
    lda (scr),y
    beq e1
    and #bankmask
    cmp sprbank
    beq e1
    lda #0
    sta (scr),y
    sta (col),y
e1: rts
.)

; Draw a single sprite.
draw_sprite:
.(
    lda spr
    sta spr_u

    ; Get position on screen.
    lda sprx
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

    ; Get shifts for left half.
    lda sprx
    and #%111
    sta sprshiftx
    lda spry
    and #%111
    sta sprshifty

    ; Draw upper left half of char.
    jsr get_spritechar
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda #8
    sec
    sbc sprshifty
    sta counter
    sta counter_u
    jsr write_sprite_l

    ldx sprshifty       ; No lower half to draw...
    beq n1

    ; Draw lower half of char.
    inc scry            ; Prepare next line.
    jsr get_spritechar
    lda spr
    clc
    adc counter_u
    sta spr
    sta spr_l
    lda sprshifty
    sta counter
    jsr write_sprite_l
    dec scry

n1:lda sprshiftx        ; No right halves to draw...
    beq n2

    ; Get shift for the right half.
    lda #8
    sec
    sbc sprshiftx
    sta sprshiftx

    ; Draw upper right
    inc scrx            ; Prepare next line.
    jsr get_spritechar
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda spr_u
    sta spr
    lda counter_u
    sta counter
    jsr write_sprite_r

    ldx sprshifty       ; No lower half to draw...
    beq n2

    ; Draw lower left
    inc scry
    jsr get_spritechar
    lda spr_l
    sta spr
    lda sprshifty
    sta counter
    jmp write_sprite_r

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
    iny
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
    rts

line_offsets_l:
    .byte 0, 22*1, 22*2, 22*3, 22*4, 22*5, 22*6, 22*7, 22*8, 22*9, 22*10, 22*11, <22*12, <22*13, <22*14, <22*15, <22*16, <22*17, <22*18, <22*19, <22*20, <22*21, <22*22
line_offsets_h:
    .byte >0, >22*1, >22*2, >22*3, >22*4, >22*5, >22*6, >22*7, >22*8, >22*9, >22*10, >22*11, >22*12, >22*13, >22*14, >22*15, >22*16, >22*17, >22*18, >22*19, >22*20, >22*21, >22*22
