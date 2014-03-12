random:
    lda last_random_value
    cmp #80
    rol
    eor vicreg_rasterlo
    cmp #80
    rol
    eor $fecd,x
    cmp #80
    rol
    sta last_random_value
    rts
