random:
    lda last_random_value
    rol
    adc #0
    eor vicreg_rasterlo
    sta last_random_value
    rts
