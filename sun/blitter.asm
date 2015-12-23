blit_clear_char:
    ldy #7
    lda #%01010101
l:  sta (d),y
    dey
    bpl -l
    rts
