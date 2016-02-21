numchars    = 128
screen      = $1000
colors      = $9400

screen_columns  = @(max-screen-columns)
screen_rows     = @(max-screen-rows screen_columns)

    data
    org $80

s:          0 0
d:          0 0
c:          0 0
scr:        0 0
col:        0 0
scrx:       0
scry:       0
curcol:     0
curchar:    0

counter:    0

result:     0
result_decimals: 0
product:    0
radius:     0
degrees:    0
xpos:       0
ypos:       0
save_x:     0
save_y:     0

last_random_value:  0
tmp:        0
tmp2:       0
tmpx:       0
tmpy:       0
countdown:  0
outer_radius: 0

cxpos:      0
cypos:      0

    end
