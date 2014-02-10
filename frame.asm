frame:
    inc framecounter

update_random:
    lda $9004
    cmp #$80
    rol
    rol
    rol
    rol
    adc $9004
    eor random
    sta random

wait_retrace:
.(  
l1: lda $9004
    bne l1
.)

switch_frame:
.(  
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char
.)

#ifdef SHOW_CHARSET
.(
    ldx #numchars-1
l2: txa
    sta screen,x
    lda #white
    sta colors,x
    dex
    bpl l2
.)
#endif

#ifndef STATIC
call_controllers:
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

    jsr draw_background
    jsr draw_sprites
    rts
