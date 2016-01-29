copy_to_color_ram:
    ldx #0
l:  lda mem,x
    sta $9500,x
    lsr
    lsr
    lsr
    lsr
    sta $9400,x
    dex
    bne -l
