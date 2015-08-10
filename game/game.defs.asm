screen_columns  = 22
screen_rows = 23
screen_width = @(* 8 screen_columns)
screen_height = @(* 8 screen_rows)

max_fire_interval = 4
min_fire_interval = 2

num_score_digits  = 8
lifes_on_screen   = @(+ screen 1)
score_on_screen   = @(+ screen 4)
hiscore_on_screen = @(+ screen 12 1)

sniper_probability             = %00111111
sniper_probability_high        = %00011111
sniper_bullet_probability      = %01111111
sniper_bullet_probability_high = %00111111
scout_interval_slow            = %01111111
scout_interval_fast            = %00111111
scout_bullet_probability       = %00111111
