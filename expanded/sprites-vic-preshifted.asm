preshift_sprites:
    lda #<preshifted_sprites
    sta sl
    lda #>preshifted_sprites
    sta @(++ sl)
    ldx #<sprite_gfx
l:  txa
    pha
    jsr preshift_sprite
    ; Step to next pair.
    lda sl
    clc
    adc #16
    sta sl
    bcc +n
    inc @(++ sl)
n:
    pla
    clc
    adc #8
    tax
    cmp #<sprite_gfx_end
    bne -l

    ; Turn sprite gfx address into indices.
    ldx #4
l:  lda sprite_inits,x
    sec
    sbc #<sprite_gfx
    lsr
    lsr
    lsr
    sta sprite_inits,x
    txa
    clc
    adc #8
    tax
    cmp #@(+ 4 (- sprite_inits_end sprite_inits))
    bne -l

    rts

; x: Index into sprite graphics.
; s: Destination buffer (8x8x2).
preshift_sprite:
    ; Copy sprite into left char of the first pair.
    ldy #0
l:  lda @(bit-and sprite_gfx #xff00),x
    sta (sl),y
    inx
    iny
    cpy #8
    bne -l

    ; Clear the right char.
    lda #0
l:  sta (sl),y
    iny
    cpy #16
    bne -l

    lda #7
    sta tmp

m:
    ; Make pointers.
    lda @(++ sl)
    sta @(++ sr)
    sta @(++ dl)
    sta @(++ dr)
    lda sl
    clc
    adc #8
    sta sr
    adc #8
    sta dl
    adc #8
    sta dr

    ; Shift the pair.
    ldx #8
    ldy #0
l:  lda (sl),y
    lsr
    sta (dl),y
    lda (sr),y
    ror
    sta (dr),y
    iny
    dex
    bne -l

    ; Step to next pair.
    lda sl
    clc
    adc #16
    sta sl
    bcc +n
    inc @(++ sl)
n:

    dec tmp
    bne -m

done:
    rts

addrs_lo:       @(maptimes [low (+ (* _ 128) preshifted_sprites)] 16)
addrs_hi:       @(maptimes [high (+ (* _ 128) preshifted_sprites)] 16)
shift_offsets:  @(maptimes [* _ 16] 8)

draw_preshifted_sprite:
    txa
    pha

    ; Get start of sprite gfx.
    ldy sprites_l,x
    lda addrs_lo,y
    sta s
    lda addrs_hi,y
    sta @(++ s)
    lda sprites_x,x
    and #7
    tay
    lda s
    ora shift_offsets,y
    sta sprite_data_top

    lda sprites_y,x
    and #7
    sta sprite_shift_y
    tay
    lda negate7,y
    sta sprite_height_top

    ; Calculate text position.
    lda sprites_x,x
    lsr
    lsr
    lsr
    sta scrx
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta scry

    lda sprites_c,x
    sta curcol

    lda sprites_x,x
    and #7
    sta tmp3

    ; Draw upper left.
    jsr scrcoladdr
    jsr get_char
    lda d
    clc
    adc sprite_shift_y
    sta d
    lda sprite_data_top
    sta s
    ldy sprite_height_top
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

    lda tmp3
    beq +n

    ; Draw upper right.
    inc scrx
    jsr get_char
    lda d
    clc
    adc sprite_shift_y
    sta d
    lda sprite_data_top
    clc     ; Step to right char in pair.
    adc #8
    sta s
    ldy sprite_height_top
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
    lda sprite_data_top
    sec
    adc sprite_height_top
    sta s
    sta sprite_data_bottom
    ldy sprite_shift_y
    dey
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

    lda tmp3
    beq +n

    ; Draw lower right.
    inc scrx
    jsr get_char
    lda sprite_data_bottom
    clc     ; Step to right char in pair.
    adc #8
    sta s
    ldy sprite_shift_y
    dey
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

n:  pla
    tax
    rts
