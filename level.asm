level_pos:  .byte 0
level_delay: .byte 0
level_old_y: .byte 0

level_data:
    .byte 4, 15
    .byte 2, 14
    .byte 2, 13
    .byte 2, 12
    .byte 2, 11
    .byte 2, 10
    .byte 2, 9
    .byte 2, 8
    .byte 2, 7
    .byte 2, 6
    .byte 10, 5
    .byte 4, 10
    .byte 4, 9
    .byte 12, 20
    .byte 4, 15
    .byte 4, 20
    .byte 4, 15
    .byte 4, 20
    .byte 4, 21
    .byte 4, 22
    .byte 10, 20
    .byte 4, 5
    .byte 4, 15
    .byte 4, 5
    .byte 4, 10
    .byte $ff

add_brick:
.(
    pha
    lda free_bricks
    and #numbricks-1
    tax
    clc
    adc #1
    and #numbricks-1
    sta free_bricks
    lda #23
    clc
    adc scrolled_chars
    sta scrbricks_x,x
    lda level_old_y
    sta scrbricks_y,x
    lda #0
    sta scrbricks_n,x
    pla
    sta scrbricks_i,x
    rts
.)
    
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
    jsr add_brick
    inc level_old_y
    lda #3
    jsr add_brick
    lda level_data,y
    sec
    sbc level_old_y
    sta scrbricks_n,x
    lda level_old_y
    clc
    adc scrbricks_n,x
    dec scrbricks_n,x
    sta level_old_y
    sta scrbricks_y,x
    dec scrbricks_y,x
    lda #5
    jsr add_brick
    jmp exit
done:
    rts

up: lda #4
    jsr add_brick
    lda #2
    jsr add_brick
    dec scrbricks_y,x
    lda level_old_y
    sec
    sbc level_data,y
    sta scrbricks_n,x
    lda level_old_y
    sec
    sbc scrbricks_n,x
    dec scrbricks_n,x
    sta level_old_y
    lda #0
    jsr add_brick

exit:
    iny
    sty level_pos
    rts
.)
