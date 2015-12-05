    ldx #0
l:  lda $9400,x
    asl
    asl
    asl
    asl
    sta tmp
    lda $9500,x
    and #$0f
    ora tmp
    tay
    lda mem,x
    sta $9500,x
    lsr
    lsr
    lsr
    lsr
    sta $9400,x
    sty mem,x
    dex
    bne -l
    rts
