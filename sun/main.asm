numchars    = 128
charset     = $1000
screen      = $1e00
colors      = $9600

charsetsize = @(* numchars 8)
charsetmask = @(-- numchars)

    data
    org $80
tmp:        0
tmp2:       0

s:          0 0
d:          0 0
c:          0 0
scr:        0 0
col:        0 0
scrx:       0
scry:       0
curcol:     0

pixel_mask: 0
pixel_yreg: 0
char_x:     0
char_y:     0

octant:     0
x0:         0
y0:         0
dx:         0
x1:         0
y1:         0
dy:         0
draw_line_error:    0
draw_line_xreg:     0
draw_line_yreg:     0

next_char:  0

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
denominator: 0

last_random_value:  0
    end

sun:

sinetab:    @(large-sine)
