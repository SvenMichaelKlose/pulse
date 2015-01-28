process_level:
.(
    ; Only do every 8th frame.
    lda scrolled_bits
    and #%111
    bne done

    ; Delay next decode depending on width of rightmost vertical edge.
    dec level_delay
    bpl done

n2: ldy level_pos       ; Get position in current pattern.
    lda level_data,y    ; Get width of bar.
    bne decode_pattern

    ; End of pattern. Get next.
    inc level_pattern
    ldy level_pattern
    lda level_patterns-1,y
    sta level_pos
    beq restart_level
    lda level_patterns,y; Copy vertical pattern offset.
    sta level_offset
    inc level_pattern
    jmp n2              ; Try again with new pattern...

restart_level:
    sta level_pattern
    sta level_pos
    beq n2

done:
    rts

decode_pattern:
    sta level_delay
    iny
    lda level_data,y    ; Get height of vertical edge.
    iny
    sty level_pos
    clc                 ; Add pattern height.
    adc level_offset
    sta tmp
    lda level_old_y
    cmp tmp
    beq done
    bcs up

down:
    ldy #1
    jsr add_tile
    inc level_old_y
    lda tmp
    clc
    sbc level_old_y
    beq n4
    bcc n4
    ldy #3
    jsr level_add_repeated_tile
    adc screen_tiles_n,x
    sta level_old_y
    sta screen_tiles_y,x
    inc level_old_y
n4: ldy #5
    bne n5

up: ldy #4
    jsr add_tile
    dec level_old_y
    lda level_old_y
    clc
    sbc tmp
    beq n3
    bcc n3
    ldy #2
    jsr level_add_repeated_tile
    sbc screen_tiles_n,x
    sta level_old_y
n3: ldy #0
n5: jmp add_tile
.)

level_add_repeated_tile:
    jsr add_tile
    sta screen_tiles_n,x
    lda level_old_y
    clc
    rts
