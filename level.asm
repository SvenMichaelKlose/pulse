process_level:
.(
    lda scrolled_bits
    and #%111
    bne done
    dec level_delay
    bpl done

n2: ldy level_pos       ; Get position in current pattern.
    lda level_data,y    ; Get length.
    bne n1
    inc level_pattern   ; Get next pattern.
    ldy level_pattern
    lda level_patterns-1,y
    sta level_pos
    beq n7              ; End of pattern list...
    lda level_patterns,y; Get pattern height.
    sta level_offset
    inc level_pattern
    jmp n2              ; Try again with new pattern...

n7: sta level_pattern   ; ...restart from first pattern.
    sta level_pos
    beq n2

done:
    rts

n1: sta level_delay
    iny
    lda level_data,y    ; Get height.
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
    lda #1
    jsr add_tile
    inc level_old_y
    lda tmp
    clc
    sbc level_old_y
    beq n4
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

up: lda #4
    jsr add_tile
    dec level_old_y
    lda level_old_y
    clc
    sbc tmp
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
    rts
.)
