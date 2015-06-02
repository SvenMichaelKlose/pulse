bonus_colors:
    green
    red
    purple
    blue
    cyan
    yellow

; Make bonus item if a scout formation has been killed.
hit_formation:
    dec formation_left_unhit
    bne sec_return
    lda sprites_x,y
    sta bonus_init
    lda sprites_y,y
    sta @(++ bonus_init)
    sty hit_formation_y
    ldy weapon
    lda bonus_colors,y
    sta @(+ bonus_init 7)
    ldy #@(- bonus_init sprite_inits)
    jsr add_sprite
    ldy hit_formation_y
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
    asl
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
r:  rts

; Bonus
bonus_fun:
    ldy sprites_d,x
    lda framecounter
    lsr
    lsr
    jsr toggle_color
    jmp move_left

; Star
star_fun:
    lda no_stars
    beq +l
    lda #black
    sta sprites_c,x
l:  lda framecounter
    lsr
    bcc -r              ; Only move star every second frame.
    lda sprites_d,x
    beq move_left_blue  ; Slow, blue star.
    bne move_left_a     ; Faster, white star.

; --

move_left_blue:
    lda #blue
    sta sprites_c,x
move_left:
    lda #1
move_left_a:
    jsr sprite_left
    jmp remove_if_sprite_is_out

; --

; Explosion
explosion_fun:
    lda sprites_d,x
    lsr
    lsr
    tay
    lda explosion_colors,y
    sta sprites_c,x
    lda sprites_l,x
    adc vicreg_rasterhi
    sta sprites_l,x
    dec sprites_d,x
    bpl move_left
    jmp remove_sprite

; Sniper
sniper_fun:
    jsr random
mod_sniper_bullet_probability:
    and #sniper_bullet_probability
    bne move_left
    jsr add_bullet
    jmp move_left

; Bullet
update_trajectory:
    jsr add_bullet_no_sound
    jmp replace_sprite

bullet_fun:
    jsr random
    and #%0000011
mod_follow:
    beq update_trajectory

    ; Initialize increment/decrement instructions.
    lda #$d6        ; dec zeropage,x
    sta +increment
    sta +step
    ldy #$f6        ; inc zeropage,x
    lda sprites_i,x
    lsr
    lsr
    lsr             ; (inc_y to carry)
    bcc +n
    sty +step
n:
    lsr             ; (inc_x to carry)
    bcc +n
    sty +increment
n:

    ldy #sprites_x
    sty @(++ +increment)
    ldy #sprites_y
    sty @(++ +step)

    lsr             ; (step_y to carry)
    bcc +n

    ; Step on larger Y.
    sty @(++ +increment)
    lda #sprites_x
    sta @(++ +step)
    lda +increment
    ldy +step
    sty +increment
    sta +step
n:

increment:
    inc sprites_y,x

    lda sprites_d,x ; Subtract high nibble from low nibble.
    tay
    lsr
    lsr
    lsr
    lsr
    sta tmp
    tya
    and #%1111
    sec
    sbc tmp
    bcs +n
step:
    inc sprites_x,x ; Step along slow axis on overflow.
n:  and #%1111      ; Put low nibble back into sprite info.
    sta tmp
    tya
    and #%11110000
    ora tmp
    sta sprites_d,x

    jsr test_foreground_collision_raw
    bcs hit_foreground
    bcc remove_if_sprite_is_out

; Scout
scout_fun:
    lda framecounter_high
    cmp #8
    bcc +l
    jsr random
    and #scout_bullet_probability
    bne +l
    jsr add_bullet
l:  lda #4
    jsr sprite_left
    lda framecounter_high
    cmp #3
    bcc +l
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
l:  jmp remove_if_sprite_is_out

; Horizontal laser
laser_fun:
    lda #11

; Lasers in general
laser_common:
    sta laser_speed_right
    jsr hit_enemy
    bcs remove_sprites
    jsr test_foreground_collision_raw
    bcs hit_foreground
    lda laser_speed_right
    jsr sprite_right

; --

remove_if_sprite_is_out:
    jsr test_sprite_out
    bcc +r
remove_sprite2:
    jmp remove_sprite

hit_foreground:
    inc sound_foreground
    bpl remove_sprite2

; Remove sprites in slot X, explode sprite Y and increment score.
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

r:  rts

; --

; Lasers
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
    lda #8
    jmp laser_common

; Player
player_fun:
    lda death_timer
    beq +n
    jsr random
    sta sprites_l,x
    sta sprites_c,x
    dec death_timer
    bne -r
    lda #<ship
    sta sprites_l,x
    lda lifes
    beq +g
    jmp restart

    ; Save hiscore to zeropage.
g:  ldx #7
l:  lda hiscore_on_screen,x
    sta hiscore,x
    dex
    bpl -l
    jmp game_over

n:  lda #cyan
    sta sprites_c,x
    lda is_invincible
    beq +n
    ldy #red
    jsr energize_color
    dec is_invincible
    jmp +l

n:  jsr test_foreground_collision_fine
    bcs die
l:  jsr find_hit
    bcs operate_joystick ; Nothing hit...

    lda sprites_fl,y
    cmp #<bonus_fun      ; Bonus.
    bne no_bonus_hit

    ; Play the "Ping!" sound.
    lda #15
    sta sound_bonus

    ; Remove bonus sprite.
    stx add_sprite_x
    tya
    tax
    jsr remove_sprite_regs_already_saved

    ; Add ten points.
    ldy #10
l:  jsr increment_score
    dey
    bne -l

    lda weapon
    cmp #5
    beq full_weapon

    inc weapon
    bne operate_joystick

full_weapon:
    jsr random
    bmi make_invincible

start_grenade:
    ; Set grenade bar X positions to that of player sprite.
    lda @(+ sprites_x 15)
    lsr
    lsr
    lsr
    sta grenade_left
    sta grenade_right

    ; Let grenade bars walk across all of the screen.
    lda #screen_width
    sta grenade_counter
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
    lda is_invincible
    bne operate_joystick

    dec lifes
    lda #120
    sta death_timer
    lda #15
    sta sound_dead
    lda #7
    sta sound_explosion
    rts

c:  lda #1
    jmp sprite_right

operate_joystick:
    lda sprites_x,x
    cmp #$f0
    bcs -c

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #joy_fire
    bne no_fire

    lda is_firing
    bne no_fire

    sty joystick_status

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
    bne +n
    lda #white
    sta sprites_c,x

    ; Shoot forward.
n:  ldy #@(- laser_init sprite_inits)
    jsr add_sprite

    lda weapon
    ldy #max_fire_interval
    lsr
    bcc +n
    ldy #min_fire_interval
n:  sty fire_interval

    lda weapon
    lsr
    beq +n

    ; Shoot downwards.
    ldy #@(- laser_down_init sprite_inits)
    jsr add_sprite

    lda weapon
    lsr
    lsr
    beq +n

    ; Shoot upwards.
    ldy #@(- laser_up_init sprite_inits)
    jsr add_sprite

n:  ldy joystick_status

no_fire:
    lda is_firing
    beq +n
    dec is_firing

    ; Joystick up.
n:  tya
    and #joy_up
    bne +n
    lda sprites_y,x
    cmp #12
    bcc +n          ; Don't bump into hiscore. ;)
    lda #4
    jsr sprite_up

    ; Joystick down.
n:  tya
    and #joy_down
    bne +n
    lda sprites_y,x
    cmp #@(-- (* (-- screen_height) 8))
    bcs +n
    lda #4
    jsr sprite_down

    ; Joystick left.
n:  tya
    and #joy_left
    bne +n
    lda sprites_x,x
    cmp #3
    bcc +n
    lda #3
    jmp sprite_left

    ; Joystick right.
n:  lda #0          ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi +n
    lda sprites_x,x
    cmp #@(* (-- screen_width) 8)
    bcs +n
    lda #3
    jmp sprite_right

n:  rts
