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

    lda #<@(+ 16 scaling_offsets)
    sta current_scaling
    lda #>scaling_offsets
    sta @(++ current_scaling)

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

    lda #0
    sta current_layer

    jsr draw_scaled_image

    ; Step to next scaling factor and draw again.
    ldx @(++ mod_scaling)
    inx
    stx current_scaling
    jmp -a

draw_scaled_image:

    ; Clear first line.
    jsr clear_line
    inc scry

    ; Set line 0 of source graphics.
    lda #0
    sta ypos

    ; Get number of source line to draw.
l:  ldy ypos
    lda (current_scaling),y
    bmi clear_line      ; End of image…

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
    tax
    plp
    php
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

clear_line:
    ; Skip if line is off–screen.
    lda scry
    cmp #screen_rows
    bcs +done

    jsr scrcoladdr

l:  jsr play_sample

    cpy #128
    bcs +n
    cpy #screen_columns
    bcs +done

    lda (scr),y
    and #layer_mask
    cmp current_layer
    bne +n

    lda #0
    sta (scr),y

n:  iny
    jmp -l

draw_scaled_line:
    jsr play_sample

    ; Skip if line is off–screen.
    lda scry
    cmp #screen_rows
    bcs +done

    ; Init self–mod pointer into scaling table.
    lda current_scaling
    sta @(+ 1 mod_scaling)
    lda @(++ current_scaling)
    sta @(+ 2 mod_scaling)

    ; Calculate screen and color RAM pointers for first pixel.
    jsr scrcoladdr  ; Get screen address of line.
    bmi +s          ; Over left side of the screen…

    ; Clear leftmost pixel.
    jsr clear_pixel
    iny

a:  jsr play_sample

mod_scaling:
l:  ldx scaling_offsets ; Get index into pixel.
    bmi clear_pixel     ; All pixels done.
    cpy #screen_columns ; Over right side of the screen?
    bcs +done       ; Yes, done.

    lda (scr),y
    and #layer_mask
    cmp current_layer
    bne +n

mod_src:
    lda $ff00,x     ; Copy character.
    sta (scr),y
mod_col:
    lda $ff00,y     ; Copy color.
    sta (col),y

n:  inc @(++ mod_scaling) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    jmp -a

    ; Step into screen from the left.
s:  inc @(++ mod_scaling) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    bmi -s          ; Still over the left side.
    jmp -a          ; Start drawing.

clear_pixel:
    jsr play_sample
    cpy #screen_rows ; Off–screen?
    bcs +done

    lda (scr),y
    and #layer_mask
    cmp current_layer
    bne +done

    lda #0
    sta (scr),y

done:
    rts

    fill @(- 256 (low *pc*))

scaling_offsets:
    @(apply #'+ (maptimes [alet (- 22 _)
                            (+ (maptimes [integer (* _ (/ 22 !))] !)
                               (list 255))]
                          22))
