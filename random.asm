random:
    lda last_random_value
    cmp #$80
    rol
    adc #0
    eor vicreg_rasterlo
    sta last_random_value
    rts
