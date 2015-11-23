block
screws_sniper:
    sniper_probability
    sniper_probability_high
    sniper_probability
    sniper_probability
end block

block
screws_sniper_bullet:
    sniper_bullet_probability
    sniper_bullet_probability
    ;sniper_bullet_probability_high
    sniper_bullet_probability
    sniper_bullet_probability
end block

block
screws_scout:
    0
    1
    0
    0
end block

block
screws_follow:
    $09
    $f0
    $f0
    $f0
end block
    
block
restart_level:
    sta level_pattern
    beq decode_position
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
    ldy level_pattern
    inc level_pattern
    lda level_patterns,y
    bmi tune_screws
    sta level_pos
    beq restart_level

    inc level_pattern
    lda @(++ level_patterns),y ; Copy vertical pattern offset.
    sta level_offset
    jmp decode_position ; Try again with new pattern...

level_add_repeated_tile:
    jsr add_tile
    sta screen_tiles_n,x
    lda level_old_y
    clc
done:
    rts

tune_screws:
    and #%111
    tax
    jsr set_screws
    bne decode_position

set_screws:
    lda screws_sniper,x
    sta @(++ mod_sniper_probability)
    lda screws_sniper_bullet,x
    sta @(++ mod_sniper_bullet_probability)
    lda screws_scout,x
    sta @(++ mod_scout)
    lda screws_follow,x
    sta mod_follow
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
    beq -done
    bcs +up

down:
    ldy #0
    jsr add_tile
    iny
    inc level_old_y
    lda tmp
    clc
    sbc level_old_y
    beq +done2
    bcc +done2
    jsr level_add_repeated_tile
    adc screen_tiles_n,x
    sta level_old_y
    sta screen_tiles_y,x
    inc level_old_y
    bne +done2

up: ldy #3
    jsr add_tile
    iny
    dec level_old_y
    lda level_old_y
    clc
    sbc tmp
    beq +done2
    bcc +done2
    jsr level_add_repeated_tile
    sbc screen_tiles_n,x
    sta level_old_y
done2:
    iny
done:
    jmp add_tile
end block
