process_level:
    ; Only do every 8th frame.
    lda scrolled_bits
    and #%111
    bne +done

    ; Delay next decode depending on width of rightmost vertical edge.
    dec level_delay
    bpl +done

decode_position:
    ldy level_pos       ; Get position in current pattern.
    lda level_data,y    ; Get width of bar.
    bne decode_pattern

    ; End of pattern. Get next.
    inc level_pattern
    ldy level_pattern
    lda @(-- level_patterns),y
    sta level_pos
    beq restart_level
    bmi tune_screws
    lda level_patterns,y; Copy vertical pattern offset.
    sta level_offset
    inc level_pattern
    jmp decode_position ; Try again with new pattern...

level_add_repeated_tile:
    jsr add_tile
    sta screen_tiles_n,x
    lda level_old_y
    clc
done:
    rts

tune_screws:
    lsr
    bcc +n
    lda #sniper_probability_fast
    ldy #$ff
l:  sta @(++ mod_sniper_probability)
    sty @(++ mod_scout_interval)
    bne decode_position
n:  lsr
    bcc +n
    lda #sniper_probability_slow
    ldy #scout_interval_fast
    bne -l
n:  lda #$f0 ; beq
    sta mod_follow
    bne decode_position

restart_level:
    sta level_pattern
    sta level_pos
    beq decode_position

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
    beq -done
    bcs +up

down:
    ldy #1
    jsr add_tile
    inc level_old_y
    lda tmp
    clc
    sbc level_old_y
    beq +n4
    bcc +n4
    ldy #3
    jsr level_add_repeated_tile
    adc screen_tiles_n,x
    sta level_old_y
    sta screen_tiles_y,x
    inc level_old_y
n4: ldy #5
    bne +n5

up: ldy #4
    jsr add_tile
    dec level_old_y
    lda level_old_y
    clc
    sbc tmp
    beq +n3
    bcc +n3
    ldy #2
    jsr level_add_repeated_tile
    sbc screen_tiles_n,x
    sta level_old_y
n3: ldy #0
n5: jmp add_tile
