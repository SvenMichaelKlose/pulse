startloop:
    jsr clear_screen

.(
    ldx #numchars-1
l1: txa
    sta screen+17*22,x
    dex
    bpl l1
.)

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
    sta tmp3

    ldy #player_init-sprite_inits
    jsr add_sprite
    ldy #bullet_init-sprite_inits
    jsr add_sprite
    ldy #laser_init-sprite_inits
    jsr add_sprite

mainloop:
.(
    jsr frame
    jmp mainloop
.)

add_sprite:
.(
    txa
    pha
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

sprite_inits:
player_init:
    .byte 02, 80, cyan,     <spr1, >spr1, <player_fun, >player_fun
laser_init:
    .byte 18, 80, white+8,  <spr2, >spr2, <laser_fun,  >laser_fun
bullet_init:
    .byte 90, 90, yellow+8, <spr3, >spr3, <bullet_fun, >bullet_fun

; Sprite handlers
; X: Current sprite number.
sprite_funs:

laser_fun:
.(
    lda sprites_x,x
    clc
    adc #15
    cmp #21*8
    bcc l1
    jmp remove_sprite
l1: sta sprites_x,x
    rts
.)

foo: .byte 200

player_fun:
.(
    lda #0
    sta $9122
    lda $9111
    bit #%00100000
    dec foo
    bne n1
    lda sprites_x,x
    clc
    adc #8
    sta laser_init
    lda sprites_y,x
    sta laser_init+1
    ldy #laser_init-sprite_inits
    jmp add_sprite
n1: rts
.)

bullet_fun:
    rts
