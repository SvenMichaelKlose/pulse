restart:
    jsr clear_screen

; Mark all sprites as dead.
.(
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
    sta addedsprites
    sta is_firing
    sta has_double_laser
    lda #8
    sta fire_interval
    jsr init_foreground

    ldy #player_init-sprite_inits
    jsr add_sprite
#ifdef foo
#ifdef STATIC
    lda player_init
    clc
    adc #11
    sta player_init
    ldy #player_init-sprite_inits
    jsr add_sprite
#endif
#endif

mainloop:
#ifndef STATIC
#ifdef BULLETS
background_stars:
.(
    lda addedsprites
    cmp #13
    bcs l1
    lda framecounter
    and #%111
    bne l1
    lda random
    and #%01111000
    sta bullet_init+1
    lda random
    and #3
    ora #8
    sta bullet_init+3
    ldy #bullet_init-sprite_inits
    jsr add_sprite
l1:
.)
#endif

add_scout:
.(
    lda framecounter
    and #%01111111
    bne l1
    lda random
    and #%01111000
    clc
    adc #16
    sta scout_formation_y
    lda #8
    sta adding_scout
    sta formation_left_unhit
    lda #3
    sta adding_scout_delay
l1:

    lda adding_scout
    beq l2
    dec adding_scout_delay
    lda adding_scout_delay
    bne l2
    lda #3
    sta adding_scout_delay
    dec adding_scout
    lda scout_formation_y
    sta scout_init+1
    ldy #scout_init-sprite_inits
    jsr add_sprite
l2:
.)
#endif
#endif

    jsr frame
#ifdef TIMING
    lda #8+blue
    sta $900f
#endif
    jmp mainloop

adding_scout:       .byte 0
adding_scout_delay: .byte 0
scout_formation_y:  .byte 0
formation_left_unhit:  .byte 0
