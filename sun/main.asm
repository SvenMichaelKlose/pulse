initial_outer_radius = @(* (? (eq *tv* :pal) 2.3 2.4) screen_columns)

mercury_countdown: @(-- (smaller-screen-axis))
mercury_x: @(-- screen_columns)
mercury_y: 0

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

l:  lsr $9004
    bne -l

    ; Configure VIC for maximum screen size.
    ldx #@(- vic_config_end vic_config 1)
l:  lda vic_config,x
    sta $9000,x
    dex
    bpl -l

    @(asm (fetch-file "shared/audio-boost.inc.asm"))

    lda #initial_outer_radius
    sta outer_radius
loop:
    lda outer_radius
    asl
    sta countdown
l:  lda outer_radius
    sta radius
    lda #@(half screen_columns)
    sta cxpos
    lda #@(half screen_rows)
    sta cypos
    lda #0
    sta curchar
    jsr draw_random_point_on_circle
    dec radius
    dec radius
    dec radius
    lda #1
    sta curchar
    jsr draw_random_point_on_circle
    dec radius
    dec radius
    dec radius
    lda #2
    sta curchar
    jsr draw_random_point_on_circle
    dec countdown
    bne -l

    ldx mercury_countdown
    beq +n

    ; Mercury fly–by.
    lda mercury_x
    sta scrx
    lda mercury_y
    sta scry
    jsr scraddr
    lda #3
    sta (scr),y

    dec mercury_x
    inc mercury_y

    lda mercury_x
    sta scrx
    lda mercury_y
    sta scry
    jsr scraddr
    lda #4
    sta (scr),y

    dec mercury_countdown
    jmp -loop

n:  dec outer_radius
    lda outer_radius
    cmp #3
    bne -loop

n:  ldx #4
l:  lda $ede4,x
    sta $9000,x
    dex
    bpl -l
    lda #0
    sta $9002

    ldx #0
l:  lda flight_loader_start,x
    sta flight_loader,x
    inx
    bne -l
    jmp flight_loader

vic_config:
    @(vic-horigin *tv* screen_columns)
    @(vic-vorigin *tv* screen_rows)
    screen_columns
    @(* 2 screen_rows)
    0
    $cd     ; Screen at $1000, chars at $1400
    0 0 0 0
    0 0 0 0
    @(+ (* light_yellow 16) 15)
    @(+ (* yellow 16) reverse)
vic_config_end:
