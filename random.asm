random:
    lda last_random_value
    asl
    adc #0
    eor vicreg_rasterlo
    sta last_random_value
    rts
