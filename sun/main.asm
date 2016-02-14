chars_per_circle = 90

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

    ldx #chars_per_circle
    stx countdown
    lda #@(* 2 screen_columns)
l:  pha
    sta radius
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
    pla
    dec countdown
    bne -l
    ldx #chars_per_circle
    stx countdown
    sec
    sbc #1
    cmp #3
    bne -l

    ldx #4
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
