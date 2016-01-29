    lda #0                                                                                                                                                    
    sta tmp
    sta scrx
    sta scry
l:  lda tmp
    jsr chrout
    lda scrx
    cmp #16
    bcc +n
    lda #0
    sta scrx
    inc scry
n:  inc tmp
    bne -l
