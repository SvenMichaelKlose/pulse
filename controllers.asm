sprite_inits:
player_init:
    .byte 02, 81, 0, cyan,     <ship, >ship, <player_fun, >player_fun
laser_init:
    .byte 18, 80, 1, white+8,  <laser, >laser, <laser_fun,  >laser_fun
laser_up_init:
    .byte 18, 80, 1, yellow,  <laser_up, >laser_up, <laser_up_fun,  >laser_up_fun
laser_down_init:
    .byte 18, 80, 1, yellow,  <laser_down, >laser_down, <laser_down_fun,  >laser_down_fun
bullet_init:
    .byte 21*8, 89, 2, yellow+8, <bullet, >bullet, <bullet_fun, >bullet_fun

laser_fun:
.(
    jsr find_hit
    bcc n1
    lda sprites_i,y
    cmp #2
    beq remove_sprite_xyf
n1: lda sprites_x,x
    clc
    adc #11
    cmp #21*8
    bcs remove_sprite2f
    sta sprites_x,x
    rts
.)

remove_sprite2f:
    lda #0
    sta is_firing
remove_sprite2:
    jmp remove_sprite

remove_sprite_xyf:
    lda #0
    sta is_firing
remove_sprite_xy:
    jsr remove_sprite
    tya
    tax
    jmp remove_sprite

laser_up_fun:
.(
    jsr find_hit
    bcc n1
    lda sprites_i,y
    cmp #2
    beq remove_sprite_xy
n1: lda sprites_x,x
    clc
    adc #8
    cmp #21*8
    bcs remove_sprite2
    sta sprites_x,x
    lda sprites_y,x
    sec
    sbc #8
    bcc remove_sprite2
    sta sprites_y,x
    rts
.)

laser_down_fun:
.(
    jsr find_hit
    bcc n1
    lda sprites_i,y
    cmp #2
    beq remove_sprite_xy
n1: lda sprites_x,x
    clc
    adc #8
    cmp #21*8
    bcs remove_sprite2
    sta sprites_x,x
    lda sprites_y,x
    clc
    adc #8
    cmp #22*8
    bcs remove_sprite2
    sta sprites_y,x
    rts
.)

has_double_laser: .byte 0
has_autofire:     .byte 0

is_firing: .byte 0
player_fun:
.(
    jsr find_hit
jmp c1 ;    bcc c1
    lda sprites_i,y
    cmp #2
    bne c1
    jmp restart
c1: lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #%00100000
    bne n1
    lda has_autofire
    bne a1
    lda is_firing
    bne n1
a1: lda framecounter    ; Little ramdomness to give the laser some action.
    lsr
    lsr
    and #7
    adc sprites_x,x
    sta laser_init
    lda sprites_x,x
    sta laser_up_init
    sta laser_down_init
    lda sprites_y,x
    sta laser_init+1
    sta laser_up_init+1
    sta laser_down_init+1
    inc laser_init+1
    lda #1
    sta is_firing
    lda has_double_laser
    beq s1
    ldy #laser_up_init-sprite_inits
    jsr add_sprite
    ldy #laser_down_init-sprite_inits
    jsr add_sprite
s1: ldy #laser_init-sprite_inits
    jmp add_sprite
n1: tya
    and #%00000100
    bne n2
    jsr sprite_up
    jsr sprite_up
    jsr sprite_up
    jsr sprite_up
n2: tya
    and #%00001000
    bne n3
    jsr sprite_down
    jsr sprite_down
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
    jsr sprite_right
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
