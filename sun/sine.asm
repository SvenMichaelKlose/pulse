sin:sty save_y
    sta tmp
    and #63
    tay
    lda tmp
    and #64
    beq no_reverse
    sty tmp2
    lda #63
    sec
    sbc tmp2
    tay
no_reverse:
    lda sinetab,y
    asl tmp
    bcc no_inverse
    jsr neg
no_inverse:
    ldy save_y
    rts

sinetab:    @(large-sine)
