num_chars    = 128
num_sprites  = 16
num_tiles    = 32
charset      = $1000
screen       = $1e00
colors       = $9600

charsetsize         = @(* num_chars 8)
charsetmask         = @(-- num_chars)
framesize           = @(half charsetsize)
framemask           = @(half num_chars)
framechars          = @(half num_chars)

first_sprite_char   = 1
num_trailing_foreground_chars  = 2

; First char of scrolling terrain.
foreground          = @(+ (half framechars) (quarter framechars))

; First char of score digits.
score_char0         = foreground

    org 0
    data

sl:                       ; Scrolling tile left of triple.
s:                    0 0 ; Source pointer.
dl:
d:                    0 0 ; Destination pointer.
sr:                       ; Scrolling tile right of triple.
scr:                  0 0 ; Screen pointer.
dr:
col:                  0 0 ; Colour RAM pointer.
scrx:                 8   ; X position.
scry:                 0   ; Y position.
curcol:               0   ; Character colour.

last_random_value:    0   ; Random number generator's last returned value.

framecounter:         0   ; Current frame number relative to start of game.
framecounter_high:    0

next_sprite_char:     0   ; Next free character for sprites.
sprite_shift_y:       0   ; Number of character line where sprite starts.
sprite_data_top:      0   ; Start of sprite data in upper chars.
sprite_data_bottom:   0   ; Start of sprite data in lower chars.
sprite_height_top:    0   ; Number of sprite lines in upper chars.
spriteframe:          0   ; Character offset into lower or upper half of charset.
sprite_rr:            0   ; Round-robin sprite allocation index.
foreground_collision: 0   ; Set if a sprite collision has been detected.
no_stars:             0   ; Draw stars in black if set to avoid trash.

scrolled_bits:        0
scrolled_chars:       0
leftmost_tile:        0
free_tiles:           0   ; Next free scrolling tile slot.
active_tiles:         0   ; Active scrolling tiles.
tilelist_r:           0 0 0 0 0 0 ; Rightmost tile of scrolling tile triples.
tiles_c:              0 0 0 0 0 0 ; Leftmost character of scrolling tile triples.
next_foreground_char: 0   ; Next free char for scrolling tiles.
sm:                   0 0 ; Scrolling tile middle.

counter:              0   ; Tile redraw counter.
repetition:           0 ; Vertical repetitions of tiles.
level_pos:            0 ; Position in level data.
level_delay:          0 ; Delay until next tile is decoded from level data.
level_old_y:          0 ; Old height of terrain.

level_pattern:        0
level_offset:         0

adding_scout:         0 ; Number of scouts in formation that need to be added.
adding_scout_delay:   0 ; Delay between scout formations.
scout_formation_y:    0 ; Centre of currently added scout formation.
formation_left_unhit: 0 ; Scouts that need to be hit until a bonus is on.
joystick_status:      0

weapon:               0 ; Weapon type.
fire_interval:        0 ; Delay counter until next laser shot gets out.
is_firing:            0
is_invincible:        0
death_timer:          0 ; Delay until game restarts after all lifes are gone.
lifes:                0 ; Number of lifes left.

sound_start:
sound_explosion:      0
sound_laser:          0
sound_bonus:          0
sound_foreground:     0
sound_dead:
sound_end:            0

grenade_counter:      0 ; Countdown until grenade effect is over.
grenade_left:         0 ; Grenade bar X positions.
grenade_right:        0

; Temporaries.
tmp:                  0
tmp2:
distance_x:           0 ; Sprite collision X distance.
tmp3:
distance_y:
collision_y_distance: 0 ; Sprite collision Y distance.

; Temporary stores for index registers.
add_sprite_x:         0
add_sprite_y:         0
draw_sprite_x:        0
hit_formation_y:      0
call_controllers_x:
draw_grenade_y:       0
laser_speed_right:    0

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

    org $f8

hiscore:    fill num_score_digits

@(check-zeropage-size)

    org $100

screen_tiles_i: fill num_tiles  ; Index into tile info.
screen_tiles_x: fill num_tiles  ; X positions.
screen_tiles_y: fill num_tiles  ; Y positions.
screen_tiles_n: fill num_tiles  ; Times duplicated along the Y axis.

    end
