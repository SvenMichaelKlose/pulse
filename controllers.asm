controllers_start:

decorative   = 32
deadly       = 64
fg_collision = 128

sprite_inits:
player_init:
    0 80 0 cyan <ship
    <player_fun >player_fun 0
laser_init:
    18 80 0 @(+ white multicolor) <laser
    <laser_fun >laser_fun 0
laser_up_init:
    18 80 0 yellow <laser_up
    <laser_up_fun >laser_up_fun 0
laser_down_init:
    18 80 0 yellow <laser_down
    <laser_down_fun >laser_down_fun 0
bullet_init:
    176 89 @(+ deadly 0) @(+ yellow multicolor) <bullet
    <bullet_fun >bullet_fun 0
scout_init:
    176 89 @(+ deadly 1) @(+ yellow multicolor) <scout
    <scout_fun >scout_fun 0
sniper_init:
    176 89 @(+ deadly 2) white <sniper
    <sniper_fun >sniper_fun 0
bonus_init:
    176 89 4 green <bonus
    <bonus_fun >bonus_fun 0
star_init:
    176 89 decorative white <star
    <star_fun >star_fun 0
explosion_init:
    176 89 decorative yellow 0
    <explosion_fun >explosion_fun 15

sinetab:
    0 0 2 4 6 10 14 14
    14 14 10 6 4 2 0 0
    0 0 254 252 248 244 240 240
    240 240 244 248 252 254 0 0

explosion_colors:
    red
    @(+ black multicolor)
    @(+ yellow multicolor)
    @(+ white multicolor)

    ; Make bonus item if a scout formation has been killed.
hit_formation:
    dec formation_left_unhit
    bne sec_return
    lda sprites_x,y
    sta bonus_init
    lda sprites_y,y
    sta @(++ bonus_init)
    tya
    pha
    ldy #@(- bonus_init sprite_inits)
    jsr add_sprite
    pla
    tay
sec_return:
    sec
    rts

hit_enemy:
    jsr find_hit
    bcs clc_return
    lda sprites_i,y
    lsr                 ; Scout?
    bcs hit_formation
    lsr                 ; Sniper?
    rts

clc_return:
    clc
return:
    rts

test_foreground_collision_fine:
    lda sprites_x,x
    and #7
    sta tmp
    lda scrolled_bits
    and #7
    cmp tmp
    bne clc_return
test_foreground_collision_raw:
    lda sprites_i,x
    asl
    rts

energize_color:
    lda framecounter
    lsr
toggle_color:
    bcc +l
    tya
    and #%1000
    ora #white
    tay
l:  sty sprites_c,x
    rts

bonus_fun:
    ldy #green
    lda framecounter
    lsr
    lsr
    jsr toggle_color
    jmp move_left

star_fun:
    lda no_stars
    beq +l
    lda #black
    sta sprites_c,x
l:  lda framecounter
    lsr
    bcc return          ; Only move star every second frame.
    lda sprites_d,x
    beq move_left_blue  ; Slow, blue star.
    bne move_left_a     ; Faster, white star.

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
    adc vicreg_rasterlo
    sta sprites_l,x
    dec sprites_d,x
    bpl move_left
    jmp remove_sprite

sniper_fun:
    jsr random
    and #sniper_bullet_probability
    bne move_left
    jsr add_bullet
    jmp move_left

a:  jsr add_bullet_no_sound
    jmp remove_sprite

bullet_fun:
    jsr random
    and #%00000111
    beq -a
    ; Initialize increment/decrement instructions.
    lda #$f6        ; inc zeropage,x
    sta +si
    sta +sw
    ldy #$d6        ; dec zeropage,x
    lda sprites_i,x
    lsr
    lsr
    lsr             ; (inc_y to carry)
    bcs +n
    sty +sw
n:
    lsr             ; (inc_x to carry)
    bcs +n
    sty +si
n:

    ldy #sprites_x
    sty @(++ +si)
    ldy #sprites_y
    sty @(++ +sw)

    lsr             ; (step_y to carry)
    bcs +n
    sty @(++ +si)
    lda #sprites_x
    sta @(++ +sw)
    lda +si
    ldy +sw
    sty +si
    sta +sw
n:

si: inc sprites_y,x

    lda sprites_d,x ; Subtract high nibble from low nibble.
    tay
    lsr
    lsr
    lsr
    lsr
    sta tmp
    tya
    and #%1111
    clc
    adc tmp
    cmp #%10000
    bcc +n1
sw: inc sprites_x,x ; Step along slow axis on underflow.
n1: and #%1111      ; Put low nibble back into sprite info.
    sta tmp
    tya
    and #%11110000
    ora tmp
    sta sprites_d,x

    jsr test_foreground_collision_raw
    bcs remove_if_on_foreground
    bcc remove_if_sprite_is_out

scout_fun:
    lda framecounter_high
    cmp #8
    bcc +l2
    jsr random
    and #scout_bullet_probability
    bne +l2
    jsr add_bullet
l2: lda #4
    jsr sprite_left
    lda framecounter_high
    cmp #3
    bcc +l1
    ldy #@(+ yellow 8)
    jsr energize_color
    lda sprites_x,x
    lsr
    lsr
    clc
    adc scrolled_chars
    and #%00011111
    tay
    lda sinetab,y
    clc
    adc scout_formation_y
    sta sprites_y,x
l1: jmp remove_if_sprite_is_out

laser_fun:
    jsr hit_enemy
    bcs remove_sprites
    jsr test_foreground_collision_raw
    bcs remove_if_on_foreground
    lda #11
    jsr sprite_right
remove_if_sprite_is_out:
    jsr test_sprite_out
    bcc return2
remove_sprite2:
    jmp remove_sprite

remove_if_on_foreground:
    inc sound_foreground
    bpl remove_sprite2

remove_sprites:
    jsr remove_sprite       ; Remove sprite in slot X.
explode:
    lda #7                  ; Start explosion sound.
    sta sound_explosion
    lda sprites_x,y         ; Initialize explosion sprite.
    sta explosion_init
    lda sprites_y,y
    sta @(++ explosion_init)
    tya                     ; Remove sprite in slot Y.
    tax
    jsr remove_sprite
    jsr increment_score     ; Increment score by 1.
    ldy #@(- explosion_init sprite_inits) ; Add explosion sprite.
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
    bcs remove_sprites
    jsr test_foreground_collision_raw
    bcs remove_if_on_foreground
    lda #8
    jsr sprite_right
    jmp remove_if_sprite_is_out

player_fun:
    lda death_timer
    beq +d1
    jsr random
    sta sprites_l,x
    sta sprites_c,x
    dec death_timer
    bne return2
    lda #<ship
    sta sprites_l,x
    dec lifes
    beq +g1
    jmp restart

g1: jmp game_over2

d1: lda #cyan
    sta sprites_c,x
    lda is_invincible
    beq +d2
    ldy #red
    jsr energize_color
    dec is_invincible
    jmp +d3

d2: jsr test_foreground_collision_fine
    bcs die
d3: jsr find_hit
    bcs operate_joystick ; Nothing hit...

    lda sprites_fl,y
    cmp #<bonus_fun      ; Bonus.
    bne no_bonus_hit

    lda #15             ; Play the "Ping!" sound.
    sta sound_bonus

    sty tmp2            ; Remove bonus sprite.
    tya
    tax
    jsr remove_sprite

    ldy #10             ; Add ten points.
l8: jsr increment_score
    dey
    bne -l8

    lda fire_interval
    cmp #min_fire_interval
    bne faster_fire         ; Increase fire speed...
    lda has_double_laser
    bne make_double_laser_or_invincible
    lda #max_fire_interval
    sta fire_interval
    inc has_double_laser
    bne operate_joystick

make_double_laser_or_invincible:
    jsr random
    lsr
    bcc make_invincible
    jsr start_grenade
    inc has_double_laser
    bne operate_joystick

make_invincible:
    lda #$ff
    sta is_invincible
    bne operate_joystick

no_bonus_hit:
    lda sprites_i,y
    and #deadly
    beq operate_joystick

die:
;#ifdef INVINCIBLE
;    jmp operate_joystick
;#else
    lda is_invincible
    bne operate_joystick
;#endif
    lda #120
    sta death_timer
    lda #15
    sta sound_dead
    lda #7
    sta sound_explosion
    rts

faster_fire:
    dec fire_interval
    dec fire_interval

operate_joystick:
    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #joy_fire
    bne no_fire

    lda is_firing
    bne no_fire

    lda framecounter    ; Little ramdomness to give the laser some action.
    lsr
    and #7
    adc sprites_x,x
    sta laser_init

    lda sprites_x,x
    sta laser_up_init
    sta laser_down_init

    lda sprites_y,x
    sta @(++ laser_init)
    sta @(++ laser_up_init)
    sta @(++ laser_down_init)
    inc @(++ laser_init)

    lda #7
    sta sound_laser

    lda fire_interval
    sta is_firing

    lda is_invincible
    bne +i2
    lda #white
    sta sprites_c,x

i2: tya                 ;Save joystick status.
    pha

    ; Shoot forward.
    ldy #@(- laser_init sprite_inits)
    jsr add_sprite

    ; Shoot downwards.
    lda has_double_laser
    beq +s1
    ldy #@(- laser_down_init sprite_inits)
    jsr add_sprite

    ; Shoot upwards.
    lda has_double_laser
    cmp #2
    bcc +s1
    ldy #@(- laser_up_init sprite_inits)
    jsr add_sprite

s1: pla
    tay

no_fire:
    lda is_firing
    beq +i1
    dec is_firing

    ; Joystick up.
i1: tya
    and #joy_up
    bne not_up
    lda sprites_y,x
    cmp #12
    bcc not_down        ; Don't bump into hiscore. ;)
    lda #4
    jsr sprite_up

not_up:
    ; Joystick down.
    tya
    and #joy_down
    bne not_down
    lda sprites_y,x
    cmp #@(-- (* 22 8))
    bcs not_down
    lda #4
    jsr sprite_down

not_down:
    ; Joystick left.
    tya
    and #joy_left
    bne not_left
    lda sprites_x,x
    cmp #3
    bcc not_right
    lda #3
    jmp sprite_left

not_left:
    ; Joystick right.
    lda #0              ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi not_right
    lda sprites_x,x
    cmp #@(* 21 8)
    bcs not_right
    lda #3
    jmp sprite_right

not_right:
    rts

game_over2:
    ; Save hiscore to zeropage.
    ldx #7
l:  lda hiscore_on_screen,x
    sta hiscore,x
    dex
    bpl -l
    jmp game_over
