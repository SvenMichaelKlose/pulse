process_level:
.(
    lda scrolled_bits
    and #%111
    bne done
    dec level_delay
    bpl done
    ldy level_pos
n2: lda level_data,y
    cmp #$ff
    bne n1
    ldy #0
    beq n2
n1: sta level_delay
    iny
    lda level_old_y
    cmp level_data,y
    bcs up

down:
    lda #1
    jsr add_tile
    inc level_old_y
    lda level_data,y
    clc
    sbc level_old_y
    bcc n4
    pha
    lda #3
    jsr add_tile
    pla
    sta screen_tiles_n,x
    lda level_old_y
    clc
    adc screen_tiles_n,x
    sta level_old_y
    sta screen_tiles_y,x
    inc level_old_y
n4: lda #5
    bne n5
done:
    rts

up: lda #4
    jsr add_tile
    dec level_old_y
    lda level_old_y
    clc
    sbc level_data,y
    beq n3
    bcc n3
    pha
    lda #2
    jsr add_tile
    pla
    sta screen_tiles_n,x
    lda level_old_y
    sec
    sbc screen_tiles_n,x
    sta level_old_y
    dec level_old_y
n3: lda #0
n5: jsr add_tile
    iny
    sty level_pos
    rts
.)
