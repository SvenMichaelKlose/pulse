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

    lda #0
    sta framecounter
    sta is_firing
    jsr init_background

    ldy #player_init-sprite_inits
    jsr add_sprite
#ifdef STATIC
    ldy #player_init-sprite_inits
    lda player_init
    clc
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    clc
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    clc
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    clc
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    clc
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    jsr add_sprite
    ldy #laser_init-sprite_inits
    jsr add_sprite
    ldy #bullet_init-sprite_inits
    jsr add_sprite
#endif

#ifdef MASSACRE
    lda #1
    sta has_double_laser
#endif

mainloop:
.(
  jmp skip
#ifndef STATIC
    lda framecounter
    and #%11111
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

#ifdef SHOW_CHARSET
    ldx #255
    lda #0
l3: sta $1000,x
    sta $1100,x
    sta $1200,x
    sta $1300,x
    dex
    bne l3
    ldx #numchars-1
l2: txa
    sta screen,x
    lda #white
    sta colors,x
    dex
    bpl l2
#endif

    jsr frame
    jmp mainloop
.)
