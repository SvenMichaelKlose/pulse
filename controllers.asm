controllers_start:

multicolor  = 8
decorative  = 32
deadly      = 64

sprite_inits:
player_init:     .byte 0, 80, 0, cyan,     <ship, <player_fun, >player_fun, 0
laser_init:      .byte 18, 80, 1, white+multicolor,  <laser, <laser_fun,  >laser_fun, 0
laser_up_init:   .byte 18, 80, 1, yellow,  <laser_up, <laser_up_fun,  >laser_up_fun, 0
laser_down_init: .byte 18, 80, 1, yellow,  <laser_down, <laser_down_fun,  >laser_down_fun, 0
bullet_init:     .byte 22*8, 89, deadly+2, yellow+multicolor, <bullet, <bullet_fun, >bullet_fun, 0
scout_init:      .byte 22*8, 89, deadly+3, yellow+multicolor, <scout, <scout_fun, >scout_fun, 0
sniper_init:     .byte 22*8, 89, deadly+3, white, <sniper, <sniper_fun, >sniper_fun, 0
bonus_init:      .byte 22*8, 89, 4, green, <bonus, <bonus_fun, >bonus_fun, 0
star_init:       .byte 22*8, 89, decorative, white, <star, <star_fun, >star_fun, 0
explosion_init:  .byte 22*8, 89, decorative, yellow, 0, <explosion_fun, >explosion_fun, 15

sinetab:
    .byte 0, 0, 1, 2, 3, 5, 7, 7
    .byte 7, 7, 5, 3, 2, 1, 0, 0
    .byte 0, 0, $ff, $fe, $fc, $fa, $f8, $f8
    .byte $f8, $f8, $fa, $fc, $fe, $ff, 0, 0

explosion_colors:
    .byte red, black+multicolor, yellow+multicolor, white+multicolor

hit_formation:
    dec formation_left_unhit
    bne sec_return
    lda sprites_x,y
    sta bonus_init
    lda sprites_y,y
    sta bonus_init+1
    tya
    pha
    ldy #bonus_init-sprite_inits
    jsr add_sprite
    pla
    tay
    sec
    rts

hit_enemy:
    jsr find_hit
    bcc return
    lda sprites_i,y
    and #%00111111
    cmp #3
    beq hit_formation
    cmp #2
    bne clc_return
sec_return:
    sec
    rts
clc_return:
    clc
return:
    rts

test_foreground_collision:
    lda sprites_i,x
    asl
    rts

energize_color:
    lda framecounter
    and #1
toggle_color:
.(
    beq n1
    tya
    and #%1000
    ora #white
    tay
n1: sty sprites_c,x
    rts
.)

bonus_fun:
.(
    ldy #green
    lda framecounter
    and #%10
    jsr toggle_color
    jmp move_left
.)

star_fun:
    lda framecounter
    lsr
    bcc return
    lda sprites_d,x
    cmp #$80
    rol
    cmp #$80
    rol
    and #3
    beq move_left_blue
    bne move_left_a
move_left_blue:
    lda #blue
    sta sprites_c,x
move_left:
    lda #1
move_left_a:
    jsr sprite_left
    jmp remove_if_sprite_is_out

explosion_fun:
    lda sprites_d,x
    lsr
    lsr
    tay
    lda explosion_colors,y
    sta sprites_c,x
    lda sprites_l,x
    adc $9004
    sta sprites_l,x
    dec sprites_d,x
    bpl move_left
    jmp remove_sprite

sniper_fun:
    lda framecounter
    and #%01011111
    bne move_left
    jsr add_bullet
    jmp move_left

bullet_fun:
.(
    lda #sprites_x
    sta si+1
    lda #sprites_y
    sta sw+1
    lda #$f6
    sta si
    sta sw
    lda sprites_i,x
    and #step_y
    beq n2
    lda #sprites_y
    sta si+1
    lda #sprites_x
    sta sw+1
n2: lda sprites_i,x
    and #dec_x
    beq n3
    lda #$d6
    sta si
n3: lda sprites_i,x
    and #dec_y
    beq n4
    lda #$d6
    sta sw
n4:
si: inc sprites_y,x
    lda sprites_d,x
    lsr
    lsr
    lsr
    lsr
    sta tmp
    lda sprites_d,x
    and #%1111
    sec
    sbc tmp
    bcs n1
sw: inc sprites_x,x
n1: and #%1111
    sta tmp
    lda sprites_d,x
    and #%11110000
    ora tmp
    sta sprites_d,x
    jsr test_foreground_collision
    bcs remove_sprite2
    bcc remove_if_sprite_is_out
.)

scout_fun:
.(
    lda framecounter_high
    cmp #8
    bcc l2
    lda random
    and #%00001111
    bne l2
    jsr add_bullet
    jsr update_random
l2: lda #4
    jsr sprite_left
    lda framecounter_high
    cmp #3
    bcc l1
    ldy #yellow+8
    jsr energize_color
    lda sprites_x,x
    lsr
    lsr
    clc
    adc scrolled_chars
    and #%00011111
    tay
    lda sinetab,y
    asl
    clc
    adc scout_formation_y
    sta sprites_y,x
l1: jmp remove_if_sprite_is_out
.)

laser_fun:
    jsr hit_enemy
    bcs remove_sprite_xy
    jsr test_foreground_collision
    bcs remove_sprite2
    lda #11
    jsr sprite_right
remove_if_sprite_is_out:
    jsr test_sprite_out
    bcc return2
remove_sprite2:
    jmp remove_sprite

remove_sprite_xy:
    jsr increment_score
    jsr remove_sprite
    lda sprites_x,y
    sta explosion_init
    lda sprites_y,y
    sta explosion_init+1
    tya
    tax
    jsr remove_sprite
    ldy #explosion_init-sprite_inits
    jmp add_sprite
return2:
    rts

laser_up_fun:
    lda #8
    jsr sprite_up
    jmp laser_side

laser_down_fun:
    lda #8
    jsr sprite_down

laser_side:
    ldy #yellow
    jsr energize_color
    jsr hit_enemy
    bcs remove_sprite_xy
    jsr test_foreground_collision
    bcs remove_sprite2
    lda #8
    jsr sprite_right
    jsr test_sprite_out
    bcs remove_sprite2
    rts

player_fun:
.(
    lda death_timer
    beq d1
    lda random
    sta sprites_l,x
    sta sprites_c,x
    dec death_timer
    bne return2
    lda #<ship
    sta sprites_l,x
    dec lifes
    beq g1
    jmp restart
g1: jmp game_over2
d1: lda is_invincible
    beq d2
    ldy #red
    jsr energize_color
    dec is_invincible
    jmp d3

d2: lda #cyan
    sta sprites_c,x
    jsr test_foreground_collision
    bcs die
d3: jsr find_hit
    bcc no_hit
    lda sprites_i,y
    and #%00111111
    cmp #4              ; Bonus.
    bne no_bonus_hit
    lda #0              ; Remove bonus sprite.
    sta sprites_fh,y
    jsr add_star
    lda fire_interval
    cmp #min_fire_interval
    bne faster_fire
    lda has_double_laser
    bne make_autofire_or_invincible
    lda #max_fire_interval
    sta fire_interval
    lda #1
    sta has_double_laser
    bne no_hit
make_autofire_or_invincible:
    lda random
    and #1
    bne make_invincible
    lda #$ff
    sta has_autofire
    bne no_hit
make_invincible:
    lda #$ff
    sta is_invincible
    bne no_hit
no_bonus_hit:
    lda sprites_i,y
    and #deadly
    beq no_hit
die:
    lda is_invincible
    bne no_hit
#ifdef INVINCIBLE
    jmp no_hit
#endif
    lda #120
    sta death_timer
    rts
faster_fire:
    dec fire_interval
    dec fire_interval
no_hit:
    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #%00100000
    bne no_fire
    lda has_autofire
    bne a1
    lda is_firing
    bne no_fire
    beq a2
a1: dec has_autofire
a2: lda framecounter    ; Little ramdomness to give the laser some action.
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
    lda fire_interval
    sta is_firing
    lda #white
    sta sprites_c,x
    tya
    pha
    ldy #laser_init-sprite_inits
    jsr add_sprite
    lda has_double_laser
    beq s1
    ldy #laser_up_init-sprite_inits
    jsr add_sprite
    ldy #laser_down_init-sprite_inits
    jsr add_sprite
s1: pla
    tay
no_fire:
    lda is_firing
    beq i1
    dec is_firing
i1: tya
    and #%00000100
    bne no_joy_up
    lda sprites_y,x
    cmp #12
    bcc no_joy_down
    lda #4
    jsr sprite_up
no_joy_up:
    tya
    and #%00001000
    bne no_joy_down
    lda sprites_y,x
    cmp #$100-8
    bcs n6
    cmp #22*8
    bcs no_joy_down
n6: lda #4
    jsr sprite_down
no_joy_down:
    tya
    and #%00010000
    bne no_joy_left
    lda sprites_x,x
    cmp #3
    bcc no_joy_right
    lda #3
    jmp sprite_left
no_joy_left:
    lda #0              ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi no_joy_right
    lda sprites_x,x
    cmp #21*8
    bcs no_joy_right
    lda #3
    jmp sprite_right
no_joy_right:
    rts
.)

game_over2:
.(
    ldx #7
l:  lda hiscore_addr,x
    sta hiscore,x
    dex
    bpl l
    jmp game_over
.)

controllers_end:
