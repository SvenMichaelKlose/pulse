numchars    = 128
charset     = $1400
screen      = $1000
colors      = $9400

screen_columns  = @(max-screen-columns)
screen_rows     = @(max-screen-rows)

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
    ; Configure VIC for maximum screen size.
    ldx #@(- vic_config_end vic_config 1)
l:  lda vic_config,x
    sta $9000,x
    dex
    bpl -l

    lda #0
    sta $900f

w:  jmp -w

vic_config:
    @(vic-horigin *tv* screen_columns)
    @(vic-vorigin *tv* screen_rows)
    screen_columns
    @(* 2 screen_rows)
    0
    $cd     ; Screen at $1000, chars at $1400
vic_config_end:

sinetab:    @(large-sine)
