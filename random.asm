random:
    lda last_random_value
    cmp #$80
    rol
    eor vicreg_rasterlo
    sta last_random_value
    rts
