restart:
    jsr clear_screen

.(
clear_sprites:
    ldx #numsprites-1
l1: lda #0
    sta sprites_fh,x
    lda #$ff
    sta sprites_ox,x
    dex
    bpl l1
.)

init_charset:
.(
    lda #0
    ldx #7
l1: sta charset,x
    dex
    bpl l1
.)

    lda #0
    sta framecounter
    sta framecounter_high
    sta addedsprites
    sta is_firing
    sta has_double_laser
    lda #8
    sta fire_interval
    jsr init_foreground

    ldy #player_init-sprite_inits
    jsr add_sprite

mainloop:
#ifdef TIMING
    lda #8+blue
    sta $900f
#endif

update_framecounter:
.(
    inc framecounter
    bne n
    inc framecounter_high
n:
.)

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
l1: lda sprites_fh,x
    beq n1
    sta m1+2
    lda sprites_fl,x
    sta m1+1
    txa
    pha
m1: jsr $1234
    pla
    tax
n1: dex
    bpl l1
.)
#endif

    jsr draw_foreground
    jsr draw_sprites
    jsr process_level
    jsr add_scout
    jmp mainloop
