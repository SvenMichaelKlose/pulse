restart:
    jsr clear_screen
.(
    ldx #255
    lda #0
l1: ;txa
    sta 0,x
    dex
    bne l1
.)

;.(
;    ldx #numchars-1
;l1: txa
;    sta screen+17*22,x
;    dex
;    bpl l1
;.)

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

mainloop:
.(
    lda framecounter
    and #%1111
    bne l1
    lda random
    and #127
    sta bullet_init+1
    ldy #bullet_init-sprite_inits
    jsr add_sprite
l1:
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
player_init: .byte 02, 80, cyan,     <spr1, >spr1, <player_fun, >player_fun
laser_init:  .byte 18, 80, white+8,  <spr2, >spr2, <laser_fun,  >laser_fun
bullet_init: .byte 21*8, 90, yellow+8, <spr3, >spr3, <bullet_fun, >bullet_fun

; Sprite handlers
; X: Current sprite number.
sprite_funs:

fired_last_time: .byte 0

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
    cmp #21*8
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

player_fun:
.(
    lda sprites_i,x
    beq c1
    jmp restart
c1: sta $1e00+21*22
    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #%00100000
    bne n0
    lda fired_last_time
    bne n1
    lda framecounter    ; Little ramdomness to give the laser some action.
    lsr
    lsr
    and #7
    adc sprites_x,x
    sta laser_init
    lda sprites_y,x
    sta laser_init+1
    lda #1
    sta fired_last_time
    ldy #laser_init-sprite_inits
    jmp add_sprite
n0: lda #0
    sta fired_last_time
n1: tya
    and #%00000100
    bne n2
    jsr sprite_up
    jsr sprite_up
n2: tya
    and #%00001000
    bne n3
    jsr sprite_down
    jsr sprite_down
n3: tya
    and #%00010000
    bne n4
    jsr sprite_left
    jsr sprite_left
n4: lda #0              ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    and #%10000000
    bne n5
    jmp sprite_right
    jmp sprite_right
n5: rts
.)

bullet_fun:
.(
    jsr sprite_left
    jsr sprite_left
    lda sprites_x,x
    bne l1
    jsr remove_sprite
l1: rts
.)
