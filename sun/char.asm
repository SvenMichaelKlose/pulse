reuse_char:
get_char_addr:
    sta tmp
    asl
    asl
    asl
    sta d
    lda tmp
    lsr
    lsr
    lsr
    lsr
    lsr
    ora #@(high charset)
    sta @(++ d)
    ldx draw_line_xreg
    ldy draw_line_yreg
    rts

alloc_char:
    inc next_char
    bne over_first
    inc next_char
over_first:
    lda next_char

fetch_char:
    and #charsetmask
    pha
    jsr get_char_addr
    jsr blit_clear_char
    pla
    rts

test_position:
    lda scrx
    cmp #22
    bcs +e
    lda scry
    cmp #23
e:  rts

get_char:
    jsr test_position
    bcs +cant_use_position
    ldy scrx
    lda (scr),y
    bne -reuse_char
    jsr alloc_char
    ldy scrx
    sta (scr),y
    ldx draw_line_xreg
    ldy draw_line_yreg
    rts

cant_use_position:
    lda #$f0
    sta @(++ d)
    ldx draw_line_xreg
    ldy draw_line_yreg
    rts
