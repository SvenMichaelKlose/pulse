radio_timer     = @(/ (cpu-cycles *tv*) (half (radio-rate *tv*)))
layer_mask      = %11110000
scaled_columns  = 22
source_columns  = 22
source_rows     = 23

flight:
    ; Set timer for sample output synchronisation.
    lda #<radio_timer
    sta $9114
    lda #>radio_timer
    sta $9115
    lda #$40
    sta $911b

    lda #0
    sta current_scaling
    lda #0
    sta current_layer

a:  
    lda current_scaling
    lsr
    sta origin_x
    lda current_scaling
    lsr
    sta origin_y
    lda #<earth_screen
    sta @(+ 1 mod_src)
    lda #>earth_screen
    sta @(+ 2 mod_src)
    lda #<earth_colours
    sta @(+ 1 mod_col)
    lda #>earth_colours
    sta @(+ 2 mod_col)

    jsr draw_scaled_image

    jsr wait_for_other_chunk

    lda chunks_loaded
    and #%11
    bne -a
    lda current_scaling
    cmp #21
    beq -a
    inc current_scaling

    jmp -a

wait_for_other_chunk:
l:  jsr play_sample
    lda chunks_loaded
    cmp last_loaded_chunk
    beq -l
    sta last_loaded_chunk
    rts

draw_scaled_image:
    ldx current_scaling
    lda scaling_addrs_l,x
    sta ptr_current_scaling
    lda scaling_addrs_h,x
    sta @(++ ptr_current_scaling)

    lda origin_x
    sta scrx
    lda origin_y
    sta scry

    ; Clear first line.
    jsr clear_line
    inc scry
    jsr clear_line
    inc scry

    ; Set line 0 of source graphics.
    lda #0
    sta ypos

    ; Get number of source line to draw.
l:  ldy ypos
    lda (ptr_current_scaling),y
    bmi +c          ; End of image…

    ; Calculate source screen and color data address of line.
    tay

    lda srclines_l,y
    clc
    adc #<earth_screen
    sta @(+ 1 mod_src)
    lda srclines_h,y
    adc #>earth_screen
    sta @(+ 2 mod_src)

    lda srclines_l,y
    clc
    adc #<earth_colours
    sta @(+ 1 mod_col)
    lda srclines_h,y
    adc #>earth_colours
    sta @(+ 2 mod_col)

    jsr draw_scaled_line

    ; Step to next line.
    inc ypos
    inc scry
    jmp -l

c:  jsr clear_line
    inc scry

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
    lda ptr_current_scaling
    sta @(+ 1 mod_scaling)
    lda @(++ ptr_current_scaling)
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
    lda $ff00,x     ; Copy color.
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
    cpy #screen_columns ; Off–screen?
    bcs +done

    lda (scr),y
    and #layer_mask
    cmp current_layer
    bne +done

    lda #0
    sta (scr),y

done:
    rts

scaling_offsets:    @(make-scaling-offsets 'scaling_offsets scaled_columns source_columns)
scaling_addrs_l:    @(make-scaling-addresses-low 'scaling_offsets scaled_columns source_columns)
scaling_addrs_h:    @(make-scaling-addresses-high 'scaling_offsets scaled_columns source_columns)

srclines_l:   @(maptimes [low (* source_columns _)] source_rows)
srclines_h:   @(maptimes [high (* source_columns _)] source_rows)

earth_screen:   @*earth-screen*
earth_colours:  @*earth-colours*
