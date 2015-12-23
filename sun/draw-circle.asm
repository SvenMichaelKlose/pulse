draw_circle:
    lda #0
    sta counter

l:  lda #45
    sta radius
    lda counter
    sta degrees
    lda #32
    sta xpos
    lda #96
    sta ypos
    jsr point_on_circle

    jsr draw_pixel

    inc counter
    bne -l
    rts
