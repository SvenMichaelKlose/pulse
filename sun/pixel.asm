draw_pixel:
    txa
    pha
    lsr
    lsr
    sta scrx
    tya
    pha
    lsr
    lsr
    lsr
    sta scry
    txa
    and #3
    sta char_x
    tya
    and #7
    sta char_y
    jsr scraddr
    jsr get_char
    ldx char_x
    ldy char_y
    lda (d),y
;    and multicolor_masks,x
    sta (d),y
    pla
    tay
    pla
    tax
    rts
