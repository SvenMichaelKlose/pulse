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
#ifndef STATIC
    lda framecounter
    and #%01111
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
    jsr frame

#ifdef SHOW_CHARSET
    ldx #numchars-1
l2: txa
    sta screen,x
    lda #white
    sta colors,x
    dex
    bpl l2
#endif

    jmp mainloop
.)

add_sprite:
.(
    txa
    pha
    ldx #15
l1: lda sprites_h,x
    bne l2
    lda sprite_inits,y
    sta sprites_x,x
    iny
    lda sprite_inits,y
    sta sprites_y,x
    iny
    lda sprite_inits,y
    sta sprites_i,x
    iny
    lda sprite_inits,y
    sta sprites_c,x
    iny
    lda sprite_inits,y
    sta sprites_l,x
    iny
    lda sprite_inits,y
    sta sprites_h,x
    iny
    lda sprite_inits,y
    sta sprites_fl,x
    iny
    lda sprite_inits,y
    sta sprites_fh,x
    pla
    tax
    rts
l2: dex
    bpl l1
    pla
    tax
    rts
.)

remove_sprite:
    lda #0
    sta sprites_h,x
    rts

sprite_up:
.(
    lda sprites_y,x
    beq e1
    dec sprites_y,x
e1: rts
.)

sprite_down:
.(
    lda sprites_y,x
    cmp #18*8
    bcs e1
    inc sprites_y,x
e1: rts
.)

sprite_left:
.(
    lda sprites_x,x
    beq e1
    dec sprites_x,x
e1: rts
.)

sprite_right:
.(
    lda sprites_x,x
    cmp #21*8
    bcs e1
    inc sprites_x,x
e1: rts
.)

find_hit:
.(
    txa
    pha
    stx tmp
    ldy #numsprites-1
l1: cpy tmp
    beq n1
    lda sprites_h,y
    beq n1

    lda sprites_x,x     ; Get X distance.
    sec
    sbc #8
    sec
    sbc sprites_x,y
    bpl l2
    clc                 ; Make it positive.
    eor #$ff
    adc #1
l2: and #%11110000
    bne n1
    lda sprites_y,x
    clc
    adc #8
    sec
    sbc sprites_y,y
    bpl l3
    clc
    eor #$ff
    adc #1
l3: and #%11110000
    beq c1
n1: dey
    bpl l1
    pla
    tax
    clc
    rts
c1: pla
    tax
    stc
    rts
.)
