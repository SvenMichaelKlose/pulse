draw_sprite:
    txa
    pha

    lda sprites_l,x
    lsr
    ora #>preshifted_sprites
    sta @(++ s)
    lda sprites_l,x
    lsr
    lda scrx
    and #7
    adc #0
    sta s
    lda sprites_y,x
    sta sprite_data_top

    lda sprites_c,x
    sta curcol

    ; Calculate text position.
    jsr xpixel_to_char
    sta scrx
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta scry

    lda sprites_y,x
    and #%111
    sta sprite_shift_y
    tay
    lda negate7,y
    sta sprite_height_top

    ; Draw upper left.
    jsr scrcoladdr
    jsr prepare_upper_blit
    sta s
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

    beq +n

    ; Draw upper right.
    inc scrx
    jsr prepare_upper_blit
    ora #64
    sta s
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l
    dec scrx

n:  lda sprite_shift_y
    beq +n

    ; Draw lower left.
    inc scry
    jsr scraddr_get_char
    lda s
    sec
    adc sprite_height_top
    sta sprite_data_bottom
    ldy sprite_shift_y
    dey
    sta s
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

    beq +n

    ; Draw lower right.
    inc scrx
    jsr get_char
    lda sprite_data_bottom
    ora #64
    ldy sprite_shift_y
    dey
    sta s
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

n:  pla
    tax
    rts
