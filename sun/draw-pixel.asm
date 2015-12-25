draw_pixel:
    cpx #screen_columns
    bcs +n
    stx scrx
    cpy #screen_rows
    bcs +n
    sty scry
    jsr scraddr
    lda curchar
    sta (scr),y
n:  rts
