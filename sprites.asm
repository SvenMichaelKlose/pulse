frame:
    lda $9004
    rol
    rol
    rol
    rol
    eor random
    adc random
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

    ; Switch to the unused buffer,
.(  
    lda sprbank
    eor #sprbufmask
    sta sprbank
    bne l1
    ora #1
l1: sta sprchar
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
    jsr blit_left

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
    jsr blit_left
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
    jsr blit_right

    lda sprshifty       ; No lower half to draw...
    beq n2

    ; Draw lower left
    inc scry
    jsr get_char
    lda spr_l
    sta spr
    ldy sprshifty
    jmp blit_right

n2: rts
.)
