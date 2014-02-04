frame:
    lda $9004
    eor random
    rol
    eor framecounter
    sta random
    inc framecounter

.(
;    lda #8+white
;    sta $900f
;    ldx #10
;l1: dex
;    bne l1
    lda #8+blue
    sta $900f
.)
    ; Switch to the unused buffer,
.(  
    lda sprbank
    eor #sprbufmask
    sta sprbank
    bne l1
    ora #1
l1: sta sprchar
.)

    ; Wait until raster beam leaves the bitmap area.
.(  
l1: lda $9004
    cmp #130-92
    bne l1
.)
.(
    lda #8+white
    sta $900f
;    ldx #10
;l1: dex
;    bne l1
;    lda #8+blue
;    sta $900f
.)

    ; Draw all sprites in the sprite table.
.(
    ldx #0
l1: lda sprites_h,x
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
    txa
    and #7
    ora #8
    sta $900f
    jsr draw_sprite
    pla
    tax
n1: inx
    cpx #numsprites
    bne l1

    lda #8+black
    sta $900f
.)

    ; Remove leftover chars.
.(
    ldx #numsprites-1
l1: lda sprites_ox,x
    cmp #$ff
    beq l4
    sta scrx
    lda sprites_oy,x
    sta scry
    jsr clear_char
    inc scrx
    jsr clear_char
    dec scrx
    inc scry
    jsr clear_char
    inc scrx
    jsr clear_char
    ldy sprites_h,x
    bne l2
    dey
    sty sprites_ox,x
    jmp l3
l4: lda sprites_h,x
    beq l3
l2: lda sprites_x,x
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
l3: dex
    bpl l1
e1:
.)

    ; Call controllers.
.(
  jmp skip
    ldx #numsprites-1
l1: lda sprites_h,x
    beq n1
    lda sprites_fl,x
    sta m1+1
    lda sprites_fh,x
    sta m1+2
    txa
    pha
m1: jsr $1234
    pla
    tax
n1: dex
    bpl l1
    skip:
.)

    rts

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
    jsr get_char
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda #8
    sec
    sbc sprshifty
    sta counter_u
    tay
    jsr write_sprite_l

    ldx sprshifty       ; No lower half to draw...
    beq n1

    ; Draw lower half of char.
    inc scry            ; Prepare next line.
    jsr get_char
    lda spr
    clc
    adc counter_u
    sta spr
    sta spr_l
    ldy sprshifty
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
    jsr get_char
    lda sprbits
    clc
    adc sprshifty
    sta sprbits
    lda spr_u
    sta spr
    ldy counter_u
    jsr write_sprite_r

    ldx sprshifty       ; No lower half to draw...
    beq n2

    ; Draw lower left
    inc scry
    jsr get_char
    lda spr_l
    sta spr
    ldy sprshifty
    jmp write_sprite_r

n2: rts
.)

write_sprite_l:
.(
l1: lda (spr),y
    ldx sprshiftx
    beq s1
s2: lsr
    dex
    bpl s2
s1: ora (sprbits),y
    sta (sprbits),y
    dey
    bne l1
    rts
.)

write_sprite_r:
.(
l1: lda (spr),y
    ldx sprshiftx
    beq s1
s2: asl
    dex
    bpl s2
s1: ora (sprbits),y
    sta (sprbits),y
    dey
    bne l1
    rts
.)
