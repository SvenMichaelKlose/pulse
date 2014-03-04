update_random:
    lda random
    cmp #80
    rol
    eor $9005
    cmp #80
    rol
    eor $fecd,x
    cmp #80
    rol
    eor random
    cmp #80
    rol
    sta random
    rts
