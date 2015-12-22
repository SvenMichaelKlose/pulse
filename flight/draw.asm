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
