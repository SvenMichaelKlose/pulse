restart:
    jsr clear_screen

; Mark all sprites as dead.
.(
    ldx #numsprites-1
l1: lda #0
    sta sprites_h,x
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
    sta addedsprites
    sta is_firing
    sta has_double_laser
    jsr init_background

    ldy #player_init-sprite_inits
    jsr add_sprite
#ifdef STATIC
    ldy #bullet_init-sprite_inits
    jsr add_sprite
#endif

mainloop:
.(
#ifndef STATIC
background_stars:
    lda addedsprites
    cmp #13
    bcs l1
    lda framecounter
    and #%111
    bne l1
    lda random
    and #127
    sta bullet_init+1
    lda random
    and #3
    ora #8
    sta bullet_init+3
    ldy #bullet_init-sprite_inits
    jsr add_sprite
l1:
#endif
skip:

    jsr frame
    jmp mainloop
.)
