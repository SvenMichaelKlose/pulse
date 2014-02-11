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
    .byte 22*8, 89, 2, yellow+8, <bullet, >bullet, <bullet_fun, >bullet_fun

hit_enemy:
.(
    jsr find_hit
    bcc n2
    lda sprites_i,y
    cmp #2
    bne n1
    stc
    rts
n1: clc
n2: rts
.)

laser_fun:
    jsr hit_enemy
    bcs remove_sprite_xyf
    lda #11
    jsr sprite_right
    jsr test_sprite_out
    bcs remove_sprite2f
    rts

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

bullet_fun:
    lda #8
    jsr sprite_left
    lda sprites_x,x
    jsr test_sprite_out
    bcs remove_sprite2
    rts

laser_up_fun:
.(
    jsr hit_enemy
    bcs remove_sprite_xy
    lda #8
    jsr sprite_right
    jsr test_sprite_out
    bcs remove_sprite2
    lda #8
    jsr sprite_up
    jsr test_sprite_out
    bcs remove_sprite2
    rts
.)

laser_down_fun:
.(
    jsr hit_enemy
    bcs remove_sprite_xy
    lda #8
    jsr sprite_right
    jsr test_sprite_out
    bcs remove_sprite2
    lda #8
    jsr sprite_down
    jsr test_sprite_out
    bcs remove_sprite2
    rts
.)

has_double_laser: .byte 0
has_autofire:     .byte 0

is_firing: .byte 0
player_fun:
.(
    lda #cyan
    sta sprites_c,x
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
    lda #fire_interval
    sta is_firing
    lda #white
    sta sprites_c,x
    tya
    pha
    lda has_double_laser
    beq s1
    ldy #laser_up_init-sprite_inits
    jsr add_sprite
    ldy #laser_down_init-sprite_inits
    jsr add_sprite
s1: ldy #laser_init-sprite_inits
    jsr add_sprite
    pla
    tay
n1: lda is_firing
    beq i1
    dec is_firing
i1: tya
    and #%00000100
    bne n2
    lda sprites_y,x
    cmp #$100-8
    bcs n2
    lda #4
    jsr sprite_up
n2: tya
    and #%00001000
    bne n3
    lda sprites_y,x
    cmp #$100-8
    bcs n6
    cmp #22*8
    bcs n3
n6: lda #4
    jsr sprite_down
n3: tya
    and #%00010000
    bne n4
    lda sprites_x,x
    beq n4
    lda #2
    jsr sprite_left
n4: lda #0              ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    and #%10000000
    bne n5
    lda sprites_x,x
    cmp #21*8
    bcs n5
    lda #2
    jmp sprite_right
n5: rts
.)
