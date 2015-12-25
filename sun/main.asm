numchars    = 128
screen      = $1000
colors      = $9400

screen_columns  = @(max-screen-columns)
screen_rows     = @(max-screen-rows screen_columns)

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
curchar:    0

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

    org $1400

charset:
    ; border color (black)
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101

    ; screen colour (yellow)
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000

    ; auxiliary colour (light yellow)
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111

    ; character colour (white)
    %10101010
    %10101010
    %10101010
    %10101010
    %10101010
    %10101010
    %10101010
    %10101010

sun:
    ; Clear screen.
    ldx #0
l:  lda #3
    sta $1000,x
    sta $1100,x
    sta $1200,x
    sta $1300,x
    lda #@(+ multicolor white)
    sta $9400,x
    sta $9500,x
    sta $9600,x
    sta $9700,x
    dex
    bne -l

    ; Configure VIC for maximum screen size.
    ldx #@(- vic_config_end vic_config 1)
l:  lda vic_config,x
    sta $9000,x
    dex
    bpl -l

    lda #@(* 2 screen_columns)
l:  pha
    sta radius
    lda #0
    sta curchar
    jsr draw_circle
    dec radius
    dec radius
    dec radius
    lda #1
    sta curchar
    jsr draw_circle
    dec radius
    dec radius
    dec radius
    lda #2
    sta curchar
    jsr draw_circle
    pla
    sec
    sbc #1
    cmp #3
    bne -l

;    ldy #<loader_cfg_flight
;    lda #>loader_cfg_flight
;    jmp tape_loader_start
w:  jmp -w

reset_vic:
    ldx #15
l:  lda $ede4,x
    sta $9000,x
    dex
    bpl -l
    rts

vic_config:
    @(vic-horigin *tv* screen_columns)
    @(vic-vorigin *tv* screen_rows)
    screen_columns
    @(* 2 screen_rows)
    0
    $cd     ; Screen at $1000, chars at $1400
    0 0 0 0 0 0 0 0
    @(* light_yellow 16)
    @(+ (* yellow 16) reverse)

vic_config_end:

sinetab:    @(large-sine)

flight_size = @(length (fetch-file (+ "obj/flight.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_flight:
    $00 $10
    <flight_size @(++ >flight_size)
    $02 $10
