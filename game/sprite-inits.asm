decorative   = 128
deadly       = 64
fg_collision = 32
t_scout      = @(+ deadly 1)
t_sniper     = @(+ deadly 2)

sprite_inits:
player_init:
    $f0 16 0          cyan <ship <player_fun >player_fun 0
laser_init:
    0 0    0          @(+ white multicolor) <laser <laser_fun >laser_fun 0
laser_up_init:
    0 0    0          yellow <laser_up <laser_up_fun >laser_up_fun 0
laser_down_init:
    0 0    0          yellow <laser_down <laser_down_fun >laser_down_fun 0
bullet_init:
    0 0    0          @(+ yellow multicolor) <bullet <bullet_fun >bullet_fun 0
scout_init:
    176 0  t_scout    scout_initial_color <scout <scout_fun >scout_fun 0
sniper_init:
    176 0  t_sniper   white <sniper <sniper_fun >sniper_fun 0
bonus_init:
    0 0    0          green <bonus <bonus_fun >bonus_fun 0
star_init:
    0 0    decorative white <star <star_fun >star_fun 0
explosion_init:
    0 0    decorative yellow 0 <explosion_fun >explosion_fun 31
sprite_inits_end:
