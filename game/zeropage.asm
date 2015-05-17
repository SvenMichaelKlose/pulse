num_chars    = 128
num_sprites  = 16
num_tiles    = 32
charset      = $1000

charsetsize         = @(* num_chars 8)
charsetmask         = @(-- num_chars)
framesize           = @(half charsetsize)
framemask           = @(half num_chars)
framechars          = @(half num_chars)

first_sprite_char   = 1
num_trailing_foreground_chars  = 2

foreground          = @(+ (half framechars) (quarter framechars))

score_char0         = foreground

    org 0
    data

s:      0 0   ; source pointer
d:      0 0   ; destination pointer
c:      0 0   ; character pointer
scr:    0 0   ; screen pointer
col:    0 0   ; colour RAM pointer
scrx:   8     ; X position
scry:   0     ; Y position
curcol: 0     ; character colour

sl:     0 0   ; scrolling tile left
sm:     0 0   ; scrolling tile middle
sr:     0 0   ; scrolling tile right

framecounter:       0
framecounter_high:  0

next_sprite_char:   0
sprite_shift_y:     0
sprite_data_top:    0
sprite_data_bottom: 0
sprite_height_top:  0
spriteframe:        0

scrolled_bits:        0
scrolled_chars:       0
leftmost_tile:        0
free_tiles:           0
next_foreground_char: 0
foreground_collision: 0

grenade_counter:      0
tmp:                  0
tmp2:
distance_x:           0
tmp3:
distance_y:           0
collision_y_distance:
counter:              0
repetition:           0

adding_scout:         0
adding_scout_delay:   0
scout_formation_y:    0
formation_left_unhit: 0

level_pos:            0
level_delay:          0
level_old_y:          0

fire_interval:        0
is_firing:            0
is_invincible:        0
death_timer:          0
lifes:                0
active_tiles:         0
tilelist_r:           0 0 0 0 0 0 0 0

sound_start:          0
sound_explosion:      0
sound_laser:          0
sound_bonus:          0
sound_foreground:     0
sound_dead:
sound_end:            0

last_random_value:    0

level_pattern:        0
level_offset:         0

no_stars:             0

grenade_left:         0
grenade_right:        0
sprite_rr:            0
weapon:               0
tiles_c:              0 0 0 0 0 0
draw_sprite_x:        0
hit_formation_y:      0
joystick_status:      0
call_controllers_x:
draw_grenade_y:       0

sprites_x:  fill num_sprites  ; X positions.
sprites_y:  fill num_sprites  ; Y positions.
sprites_i:  fill num_sprites  ; Flags.
                              ; 7 = decorative
                              ; 6 = deadly
                              ; 5 = foreground collision
                              ; 4 = bullet Y step
                              ; 3 = bullet increment X
                              ; 2 = bullet increment Y
                              ; 1-0 = 01 sniper 10 scout
sprites_c:  fill num_sprites  ; Colors.
sprites_l:  fill num_sprites  ; Low character addresses.
sprites_fl: fill num_sprites  ; Function controlling the sprite (low).
sprites_fh: fill num_sprites  ; Function controlling the sprite (high).
sprites_d:  fill num_sprites  ; Whatever the controllers want.
                              ; Bullet:    SSSSCCCC step and counter
                              ; Star:      pixels/odd frames, 0 is 1 in blue
                              ; Explosion: position in explosion_colors
sprites_ox: fill num_sprites  ; Former X positions for cleaning up.
sprites_oy: fill num_sprites  ; Former Y positions for cleaning up.

hiscore:    fill num_score_digits

    org $100

screen_tiles_i: fill num_tiles  ; Index into tile info.
screen_tiles_x: fill num_tiles  ; X positions.
screen_tiles_y: fill num_tiles  ; Y positions.
screen_tiles_n: fill num_tiles  ; Times duplicated along the Y axis.

    end
