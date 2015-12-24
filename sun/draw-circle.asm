draw_circle:
    lda #0
    sta counter

l:  lda counter
    sta degrees
    lda #@(half screen_columns)
    sta xpos
    lda #@(half screen_rows)
    sta ypos
    jsr point_on_circle

    jsr draw_pixel

    inc counter
    bne -l
    rts
