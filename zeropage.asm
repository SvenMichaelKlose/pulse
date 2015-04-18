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
distance_x              = tmp
tmp2                    = $1b
distance_y              = tmp2
tmp3                    = $1c
collision_y_distance    = tmp3
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
has_double_laser        = $27
has_autofire            = $28
is_firing               = $29
is_invincible           = $2a
death_timer             = $2b
lifes                   = $2c
active_tiles            = $2d
tilelist_r              = $2e ; 8 bytes

sound_start             = $36
sound_explosion         = $36
sound_laser             = $37
sound_bonus             = $38
sound_foreground        = $39
sound_dead              = $3a
sound_end               = sound_dead

last_random_value       = $3b

level_pattern           = $3c
level_offset            = $3d

no_stars                = $3e

grenade_left            = $3f
grenade_right           = $40
tiles_c                 = $41 ; 6 bytes

sprites_x   = $50   ; X positions.
sprites_y   = $60   ; Y positions.
sprites_i   = $70   ; Flags.
                    ; 7 = foreground collision
                    ; 6 = decorative
                    ; 5 = deadly
                    ; 4-0 = sprite type
sprites_c   = $80   ; Colors.
sprites_l   = $90   ; Low character addresses.
sprites_fl  = $a0   ; Function controlling the sprite (low).
sprites_fh  = $b0   ; Function controlling the sprite (high).
sprites_d   = $c0   ; Whatever the controllers want.
sprites_ox  = $d0   ; Former X positions for cleaning up.
sprites_oy  = $e0   ; Former Y positions for cleaning up.

hiscore     = $f8

screen_tiles_i = $100  ; Index into tile info.
screen_tiles_x = $120  ; X positions.
screen_tiles_y = $140  ; Y positions.
screen_tiles_n = $160  ; Times duplicated along the Y axis.
