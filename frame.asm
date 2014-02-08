frame:
    inc framecounter
    lda $9004
    cmp #$80
    rol
    rol
    rol
    rol
    adc $9004
    eor random
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

    jsr draw_background
    jmp draw_sprites
