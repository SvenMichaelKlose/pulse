radio_timer     = @(/ (cpu-cycles *tv*) (radio-rate *tv*))
layer_mask      = %11110000
scaled_columns  = 22
source_columns  = 22
source_rows     = 23

flight:
l:  lda do_play_radio
    beq -l

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
    and #%1
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

earth_screen:   @*earth-screen*
earth_colours:  @*earth-colours*
