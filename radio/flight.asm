radio_timer = @(/ (cpu-cycles *tv*) (half (radio-rate *tv*)))
layer_mask = %11110000

flight:
    ; Set timer for sample output synchronisation.
    lda #<radio_timer
    sta $9114
    lda #>radio_timer
    sta $9115
    lda #$40
    sta $911b

    lda #<scaling_offsets
    sta current_scaling_x
    lda #>scaling_offsets
    sta @(++ current_scaling_x)
    lda #<scaling_offsets
    sta current_scaling_y
    lda #>scaling_offsets
    sta @(++ current_scaling_y)
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
    lda (current_scaling_y),y
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

    jsr draw_scaled_line

    ; Step to next line.
    inc ypos
    inc scry
    jmp -l

o:
    ; Clear last line.
    inc scry
    jsr clear_line

    ; Step to next scaling factor and draw again.
    ldx @(++ mod_scaling)
    inx
    stx current_scaling_x
    stx current_scaling_Y
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

draw_scaled_line:
    ; Skip if line is off–screen.
    lda scry
    cmp #23
    bcs +done

    ; Init self–mod pointer into scaling table.
    lda current_scaling_x
    sta @(++ mod_scaling)
    lda @(++ current_scaling_x)
    sta @(+ 2 mod_scaling)

    ; Calculate screen and color RAM pointers for first pixel.
    jsr scrcoladdr  ; Get screen address of line.
    bmi +s          ; Over left side of the screen…

a:  jsr play_sample

mod_scaling:
l:  ldx scaling_offsets    ; Get index into pixel.
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
n:  inc @(++ mod_scaling) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    jmp -a

    ; Step into screen from the left.
s:  inc @(++ mod_scaling) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    bmi -s          ; Still over the left side.
    jmp -a          ; Start drawing.

done:
    rts

    fill @(- 256 (low *pc*))

scaling_offsets:
    @(apply #'+ (maptimes [alet (- 22 _)
                            (+ (maptimes [integer (* _ (/ 22 !))] !)
                               (list 255))]
                          22))
