level_data:
    .byte 16, 20
    .byte 2, 19
    .byte 2, 18
    .byte 4, 17
    .byte 2, 16
    .byte 2, 15
    .byte 2, 14
    .byte 2, 13
    .byte 2, 12
    .byte 2, 11
    .byte 16, 10
    .byte 16, 9

;    .byte 12, 20
;    .byte 16, 15
;    .byte 16, 20
;    .byte 16, 15

    .byte 16, 20
    .byte 16, 21
    .byte 16, 22
    .byte 32, 20
    .byte 16, 5
    .byte 16, 22
    .byte 16, 5
    .byte 16, 22
    .byte $ff

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
    jmp n2
n1: sta level_delay
    iny
    lda level_old_y
    cmp level_data,y
    beq exit
    bcs up

down:
    lda #1
    jsr add_tile
    inc level_old_y
    lda level_data,y
    sec
    sbc level_old_y
    sec
    sbc #1
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
    sec
    sbc level_data,y
    sec
    sbc #1
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

exit:
    iny
    sty level_pos
    rts
.)
