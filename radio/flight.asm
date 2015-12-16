radio_timer = @(/ (cpu-cycles *tv*) (half (radio-rate *tv*)))
layer_mask = %11110000

    org $1000
    $02 $10

    jmp start

    fill @(* 6 8)

chars:
    $00 $00 $00 $00 $00 $00 $00 $00
    $AA $AA $AA $AA $AA $AA $AA $AA
    $AA $00 $AA $00 $AA $00 $AA $00
    $FF $FF $FF $FF $FF $FF $FF $FF
    $FF $00 $FF $00 $FF $00 $FF $00
    $00 $00 $00 $00 $00 $00 $00 $00
chars_end:

start:
    ; Wait for retrace.
l:  lsr $9004
    bne -l

    ; Charset at $1000.
    lda #%11111100
    sta $9005

    ; Copy character data to $1000.
    ldx #@(- chars_end chars)
l:  lda chars,x
    sta $1000,x
    dex
    bpl -l

    ; Clear the screen.
    ldx #252
    lda #0
l:  sta screen,x
    sta @(+ 253 screen),x
    dex
    bne -l

load_8k:
    ldx #5
l:  lda loader_cfg_8k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start

    ; Init sample playing and halt until first buffer has been loaded.
    lda #0
    sta rr_sample
    sta do_play_radio
l:  lda do_play_radio
    beq -l

    jmp flight

init_8k:
    ; Set patch vector called by game.
    lda model
    lsr
    beq +n
    jsr $2002
n:

    ; Load +16K block.
    ldx #5
l:  lda loader_cfg_16k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_16k:
    ; Load +24K block.
    ldx #5
l:  lda loader_cfg_24k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_24k:
    ; Load +32K block.
    ldx #5
l:  lda loader_cfg_32k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_32k:
    ; Blank screen.
    lda #0
    sta $9002

    ; Load splash screen.
    ldx #5
l:  lda loader_cfg_splash,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start

flight:
    ; Set timer for sample output synchronisation.
    lda #<radio_timer
    sta $9114
    lda #>radio_timer
    sta $9115
    lda #$40
    sta $911b

    lda #<zoomtabs
    sta current_zoom_x
    lda #>zoomtabs
    sta @(++ current_zoom_x)
    lda #<zoomtabs
    sta current_zoom_y
    lda #>zoomtabs
    sta @(++ current_zoom_y)
a:  lda #0
    sta scrx
    sta scry
    lda #<gfx_earth
    sta @(+ 1 mod_src)
    lda #>gfx_earth
    sta @(+ 2 mod_src)
    lda #<colors_earth
    sta @(+ 1 mod_col)
    lda #>colors_earth
    sta @(+ 2 mod_col)
    lda #blue
    sta curcol

    lda #0
    sta ypos
    sta current_layer

    ; Clear first line.
    jsr clear_line
    inc scry

    ; Get number of source line to draw.
l:  ldy ypos
    lda (current_zoom_y),y
    bmi +o      ; End of image…

    ; Calculate source screen and color data address of line.
    tay
    lda $edfd,y
    tax
    clc
    adc #<gfx_earth
    php
    sta @(+ 1 mod_src)
    txa
    clc
    adc #<colors_earth
    sta @(+ 1 mod_col)
    cpy #@(++ (/ 256 screen_columns))
    lda #@(half (high screen))
    rol
    plp
    php
    tax
    adc #@(+ (- (high screen)) (high gfx_earth))
    sta @(+ 2 mod_src)
    plp
    txa
    adc #@(+ (- (high screen)) (high colors_earth))
    sta @(+ 2 mod_col)

    jsr draw_zoomed_line

    ; Step to next line.
    inc ypos
    inc scry
    jmp -l

o:
    ; Clear last line.
    inc scry
    jsr clear_line

    ; Step to next scaling factor and draw again.
    ldx @(++ mod_zoom)
    inx
    stx current_zoom_x
    stx current_zoom_Y
    jmp -a

play_sample:
    ; Check if we need to play a sample.
    lda $911d           ; Get timer 1/VIA 1 underflow bit.
    asl                 ; Shift it into the M flag.
    bpl +done           ; Nothing to be played, yet…

    ; Reset timer.
    lda #>radio_timer
    sta $9115

    stx save_x
    ldx rr_sample
mod_sample_getter:
    lda sample_buffer,x
    sta $900e
    dex
    stx rr_sample
    ldx save_x
done:
    rts

clear_line:
    lda scry
    cmp #23
    bcs -done
    jsr scrcoladdr
l:  ldy scrx
    bmi +n
    cmp #22
    bcs -done
    lda (scr),y
    and #layer_mask
    cmp current_layer
    bne +n
    lda #0
    sta (scr),y
n:  iny
    jmp -l

draw_zoomed_line:
    ; Skip if line is off–screen.
    lda scry
    cmp #23
    bcs +done

    ; Init self–mod pointer into scaling table.
    lda current_zoom_x
    sta @(++ mod_zoom)
    lda @(++ current_zoom_x)
    sta @(+ 2 mod_zoom)

    ; Calculate screen and color RAM pointers for first pixel.
    jsr scrcoladdr  ; Get screen address of line.
    bmi +s          ; Over left side of the screen…

a:  jsr play_sample

mod_zoom:
l:  ldx zoomtabs    ; Get index into pixel.
    bmi +done       ; All pixels done.
    cpy #23         ; Over right side of the screen?
    bcs +done       ; Yes, done.
    lda (scr),y
    and #layer_mask
    cmp current_layer
    bne +n
mod_src:
    lda $ff00,x     ; Get pixel.
    sta (scr),y     ; Set pixel.
mod_col:
    lda $ff00,y     ; Get color.
    sta (col),y     ; Set color.
n:  inc @(++ mod_zoom) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    jmp -a

    ; Step into screen from the left.
s:  inc @(++ mod_zoom) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    bmi -s          ; Still over the left side.
    jmp -a          ; Start drawing.

done:
    rts

patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))
patch_16k_size = patch_8k_size
patch_24k_size = patch_8k_size
patch_32k_size = patch_8k_size
splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_8k:
    $00 $20
    <patch_8k_size @(++ >patch_8k_size)
    <init_8k >init_8k

loader_cfg_16k:
    $00 $40
    <patch_16k_size @(++ >patch_16k_size)
    <init_16k >init_16k

loader_cfg_24k:
    $00 $60
    <patch_24k_size @(++ >patch_24k_size)
    <init_24k >init_24k

loader_cfg_32k:
    $00 $a0
    <patch_32k_size @(++ >patch_32k_size)
    <init_32k >init_32k

loader_cfg_splash:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10

    fill @(- 256 (low *pc*))

zoomtabs:
    @(apply #'+ (maptimes [alet (- 22 _)
                            (+ (maptimes [integer (* _ (/ 22 !))] !)
                               (list 255))]
                          22))
