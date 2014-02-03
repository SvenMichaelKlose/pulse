startloop:
    jsr clear_screen

;.(
;    ldx #numchars-1
;l1: txa
;    sta screen+17*22,x
;    dex
;    bpl l1
;.)

.(
    lda #0
    sta sprbank
    ldx #7
l1: sta chars,x
    dex
    bpl l1
.)

.(
    lda #0
    ldx #numsprites-1
l1: sta sprites_ox,x
    sta sprites_oy,x
    sta sprites_h,x
    dex
    bpl l1
.)

    lda #0
    sta tmp3

    ldy #player_init-sprite_inits
    jsr add_sprite
    lda #40
    sta player_init
    sta player_init+1
    ldy #player_init-sprite_inits
    jsr add_sprite

mainloop:
    jsr frame
    jmp mainloop

add_sprite:
.(
    ldx #15
l1: lda sprites_h,x
    bne l2
    tya
    sta sprites_i,x
    lda sprite_inits,y
    sta sprites_x,x
    iny
    lda sprite_inits,y
    sta sprites_y,x
    iny
    lda sprite_inits,y
    sta sprites_c,x
    iny
    lda sprite_inits,y
    sta sprites_l,x
    iny
    lda sprite_inits,y
    sta sprites_h,x
    rts
l2: dex
    bpl l1
    rts
.)

sprite_inits:
player_init:
    .byte 2, 80, cyan, <spr1, >spr1
