;#ifdef M3K
;numchars    = 256
;#else
numchars    = 128
;#endif

numsprites  = 16
numtiles    = 32
charset     = $1000

charsetsize         = @(* numchars 8)
charsetmask         = @(-- numchars)
framesize           = @(half charsetsize)
framemask           = @(half numchars)
framechars          = @(half numchars)

first_sprite_char   = 1
num_trailing_foreground_chars  = 2

foreground          = @(+ (half framechars) (quarter framechars))

score_char0         = foreground

s                       = $00   ; source pointer
d                       = $02   ; destination pointer
c                       = $04   ; character pointer
scr                     = $04   ; screen pointer
col                     = $06   ; colour RAM pointer
scrx                    = $08   ; X position
scry                    = $09   ; Y position
curcol                  = $0a   ; character colour

sl                      = $04   ; scrolling tile left
sm                      = $06   ; scrolling tile middle
sr                      = $08   ; scrolling tile right

framecounter            = $0b
framecounter_high       = $0c

next_sprite_char        = $0d
sprite_shift_y          = $0e
sprite_data_top         = $0f
sprite_data_bottom      = $10
sprite_height_top       = $11
spriteframe             = $12

scrolled_bits           = $13
scrolled_chars          = $14
leftmost_tile           = $15
free_tiles              = $16
next_foreground_char    = $17
foreground_collision    = $18

grenade_counter         = $19
tmp                     = $1a
tmp2                    = $1b
distance_x              = tmp2
tmp3                    = $1c
collision_y_distance    = tmp3
distance_y              = tmp3
counter                 = $1d
repetition              = $1e

adding_scout            = $1f
adding_scout_delay      = $20
scout_formation_y       = $21
formation_left_unhit    = $22

level_pos               = $23
level_delay             = $24
level_old_y             = $25

fire_interval           = $26
is_firing               = $27
is_invincible           = $28
death_timer             = $29
lifes                   = $2a
active_tiles            = $2b
tilelist_r              = $2c ; 8 bytes

sound_start             = $34
sound_explosion         = $34
sound_laser             = $35
sound_bonus             = $36
sound_foreground        = $37
sound_dead              = $38
sound_end               = sound_dead

last_random_value       = $39

level_pattern           = $3a
level_offset            = $3b

no_stars                = $3c

grenade_left            = $3d
grenade_right           = $3e
sprite_rr               = $3f
weapon                  = $40
tiles_c                 = $41 ; 6 bytes
draw_sprite_x           = $47
hit_formation_y         = $48
joystick_status         = $49
draw_grenade_y          = $4a
call_controllers_x      = draw_grenade_y

sprites_x   = $50   ; X positions.
sprites_y   = $60   ; Y positions.
sprites_i   = $70   ; Flags.
                    ; 7 = decorative
                    ; 6 = deadly
                    ; 5 = foreground collision
                    ; 4 = bullet Y step
                    ; 3 = bullet increment X
                    ; 2 = bullet increment Y
                    ; 1-0 = 01 sniper 10 scout
sprites_c   = $80   ; Colors.
sprites_l   = $90   ; Low character addresses.
sprites_fl  = $a0   ; Function controlling the sprite (low).
sprites_fh  = $b0   ; Function controlling the sprite (high).
sprites_d   = $c0   ; Whatever the controllers want.
                    ; Bullet:    SSSSCCCC step and counter
                    ; Star:      pixels/odd frames, 0 is 1 in blue
                    ; Explosion: position in explosion_colors
sprites_ox  = $d0   ; Former X positions for cleaning up.
sprites_oy  = $e0   ; Former Y positions for cleaning up.

hiscore     = $f8

screen_tiles_i = $100  ; Index into tile info.
screen_tiles_x = $120  ; X positions.
screen_tiles_y = $140  ; Y positions.
screen_tiles_n = $160  ; Times duplicated along the Y axis.
