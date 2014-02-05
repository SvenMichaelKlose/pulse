frame:
    lda $9004
    eor random
    rol
    eor framecounter
    sta random

#ifdef TIMING
.(
    lda #8+blue
    sta $900f
.)
#endif

    ; Wait until raster beam leaves the bitmap area.
.(  
l1: lda $9004
    bne l1
.)
#ifdef TIMING
.(
    lda #8+white
    sta $900f
.)
#endif

    ; Switch to the unused buffer,
.(  
    lda sprbank
    eor #sprbufmask
    sta sprbank
    bne l1
    ora #1
l1: sta sprchar
.)

bg = $1000+63*8

.(
    lda #<background
    sta spr
    lda #>background
    sta spr+1
    lda #$f8
    sta d
    ldx #$11
    lda sprbank
    beq n1
    ldx #$13
n1: stx d+1
    ldy #7
    lda #0
l1: sta (d),y
    dey
    bpl l1
    lda #0
    sec
    sbc framecounter
    and #%110
    sta sprshiftx
    ldy #8
    jsr write_sprite_l
    lda #8
    sec
    sbc sprshiftx
    sta sprshiftx
    ldy #8
    jsr write_sprite_r
.)

.(
    lda #<background2
    sta spr
    lda #>background2
    sta spr+1
    lda #$f0
    sta d
    ldx #$11
    lda sprbank
    beq n1
    ldx #$13
n1: stx d+1
    ldy #7
    lda #0
l1: sta (d),y
    dey
    bpl l1
    lda #0
    sec
    sbc framecounter
    and #%110
    sta sprshiftx
    ldy #8
    jsr write_sprite_l
    lda #8
    sec
    sbc sprshiftx
    sta sprshiftx
    ldy #8
    jsr write_sprite_r
.)

.(
    lda framecounter
    bne n1
    ldx #22
l1: lda #$3f
    sta screen+20*22,x
    lda #$3e
    sta screen+21*22,x
    sta screen+22*22,x
    lda #yellow+8
    sta colors+20*22,x
    sta colors+21*22,x
    sta colors+22*22,x
    dex
    bpl l1
    n1:
.)
    
    ; Draw all sprites.
.(
    ldx #0
l1: lda sprites_h,x     ; Skip unallocated sprites.
    beq n1

    sta spr+1
    lda sprites_l,x
    sta spr

#ifdef TIMING
    txa
    and #7
    ora #8
    sta $900f
#endif

    txa
    pha
    jsr draw_sprite
    pla
    tax

n1: inx
    cpx #numsprites
    bne l1
.)

    ; Remove leftover chars.
.(
    ldx #numsprites-1
l1: lda sprites_ox,x
    cmp #$ff
    beq n2
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
    lda #$ff
    sta sprites_ox,x
n2: lda sprites_h,x
    beq n1
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
n1: dex
    bpl l1
.)

#ifdef TIMING
    lda #8+black
    sta $900f
#endif

#ifndef STATIC
    ; Call controllers.
.(
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
.)
#endif

#ifdef TIMING
    lda #8+white
    sta $900f
#endif

    inc framecounter
    rts

; Draw a single sprite.
draw_sprite:
.(
    lda spr
    sta spr_u

    lda sprites_c,x
    sta curcol

    ; Get position on screen.
    lda sprites_x,x
    clc
    lsr
    lsr
    lsr
    sta scrx
    lda sprites_y,x
    clc
    lsr
    lsr
    lsr
    sta scry

    ; Get shifts
    lda sprites_x,x
    and #%111
    sta sprshiftx
    sta sprshiftxl
    lda sprites_y,x
    and #%111
    sta sprshifty

    ; Draw upper left half of char.
    jsr get_char
    lda d
    clc
    adc sprshifty
    sta d
    lda #8
    sec
    sbc sprshifty
    sta counter_u
    tay
    jsr write_sprite_l

    lda sprshifty       ; No lower half to draw...
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
    lda d
    clc
    adc sprshifty
    sta d
    lda spr_u
    sta spr
    ldy counter_u
    jsr write_sprite_r

    lda sprshifty       ; No lower half to draw...
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
    dey
l1: lda (spr),y
    ldx sprshiftx
    beq s1
s2: lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
s1: ora (d),y
    sta (d),y
    dey
    bpl l1
    rts
.)

write_sprite_r:
.(
    dey
l1: lda (spr),y
    ldx sprshiftx
    beq s1
s2: asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
s1: ora (d),y
    sta (d),y
    dey
    bpl l1
    rts
.)
