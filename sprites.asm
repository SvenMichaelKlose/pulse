add_sprite:
.(
    txa
    pha
    tya
    pha
    ldx #numsprites-1   ; Look for free slot.
l1: lda sprites_fh,x
    beq l2
    dex
    bpl l1
    ldx #numsprites-1   ; None available. Look for decorative sprite.
l4: lda sprites_i,x
    and #32
    bne l2
    dex
    bpl l4
    jmp done            ; None available. Job remains undone.

l2: lda #sprites_x      ; Copy descriptor to sprite table.
    sta selfmod+1
l3: lda sprite_inits,y
selfmod:
    sta sprites_x,x
    iny
    lda selfmod+1
    cmp #sprites_d
    beq done
    clc
    adc #$10
    sta selfmod+1
    jmp l3
done:
    pla
    tay
    pla
    tax
    rts
.)

remove_sprite:
    lda #0
    sta sprites_fh,x
    jmp add_star

sprite_up:
.(
    eor #$ff
    clc
    adc #1
.)

sprite_down:
.(
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts
.)

sprite_left:
.(
    eor #$ff
    clc
    adc #1
.)

sprite_right:
.(
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts
.)

test_sprite_out:
.(
    lda sprites_x,x
    cmp #22*8
    bcs c1
    lda sprites_y,x
    cmp #23*8
c1: rts
.)

find_hit:
.(
    txa
    pha
    stx tmp
    ldy #numsprites-1
l1: cpy tmp
    beq n1
    lda sprites_fh,y
    beq n1
    lda sprites_i,y
    and #32
    bne n1

    lda sprites_x,x     ; Get X distance.
    clc
    adc #8
    sec
    sbc sprites_x,y
    bpl l2
    clc                 ; Make it positive.
    eor #$ff
    adc #1
l2: and #%11110000
    bne n1
    lda sprites_y,x
    clc
    adc #8
    sec
    sbc sprites_y,y
    bpl l3
    clc
    eor #$ff
    adc #1
l3: and #%11110000
    beq c1
n1: dey
    bpl l1
    pla
    tax
    clc
    rts
c1: pla
    tax
    stc
    rts
.)

draw_sprites:
.(
draw_decorative_sprites:
    ldx #numsprites-1
l2: lda sprites_fh,x
    beq n3
    lda sprites_i,x
    and #decorative
    beq n3
    txa
    pha
    jsr draw_sprite
    pla
    tax
n3: dex
    bpl l2

draw_other_sprites:
    ldx #numsprites-1
l1: lda sprites_fh,x
    beq n1
    lda sprites_i,x
    and #decorative
    bne n1

    lda #0
    sta foreground_collision
    txa

    pha
#ifdef TIMING
    eor #%111
    ora #8
    sta $900f
#endif
    jsr draw_sprite
    pla
    tax

save_foreground_collision:
    lda sprites_i,x
    and #%01111111
    ldy foreground_collision
    beq n2
    ora #128
n2: sta sprites_i,x

n1: dex
    bpl l1
.)

clean_screen:
.(
#ifdef TIMING
    lda #8+white
    sta $900f
#endif
    ldx #numsprites-1
l1: lda sprites_ox,x
    cmp #$ff
    beq n2
    sta scrx
    lda sprites_oy,x
    sta scry
    jsr clear_char
    inc scrx
    jsr clear_char
    dec scrx
    inc scry
    jsr clear_char
    inc scrx
    jsr clear_char
    lda #$ff
    sta sprites_ox,x
n2: lda sprites_fh,x
    beq n1
    lda sprites_x,x
    lsr
    lsr
    lsr
    sta sprites_ox,x
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta sprites_oy,x
n1: dex
    bpl l1
.)
#ifdef TIMING
    lda #8+blue
    sta $900f
#endif
    rts

; Draw a single sprite.
draw_sprite:
.(
    lda #>sprite_gfx
    sta s+1
    lda sprites_l,x
    sta s
    sta sprite_data_top

    lda sprites_c,x
    sta curcol

bitmap_to_text_position:
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

configure_blitter:
    lda sprites_x,x
    and #%111
    sta blitter_shift_left
    lda #8
    sec
    sbc blitter_shift_left
    sta blitter_shift_right
    lda sprites_y,x
    and #%111
    sta sprite_shift_y
    lda #8
    sec
    sbc sprite_shift_y
    sta sprite_height_top

    ; Draw upper left.
    jsr get_char
    lda d+1
    beq n3
    lda d
    clc
    adc sprite_shift_y
    sta d
    ldy sprite_height_top
    lda sprite_data_top
    dey
    jsr blit_left

n3: lda sprite_shift_y
    beq n1

    ; Draw lower left.
    inc scry
    jsr get_char
    lda s
    clc
    adc sprite_height_top
    sta sprite_data_bottom
    lda d+1
    beq n6
    lda sprite_data_bottom
    ldy sprite_shift_y
    dey
    jsr blit_left
n6: dec scry

n1: lda blitter_shift_left
    beq n2

    ; Draw upper right.
    inc scrx
    jsr get_char
    lda d+1
    beq n4
    lda d
    clc
    adc sprite_shift_y
    sta d
    ldy sprite_height_top
    lda sprite_data_top
    dey
    jsr blit_right

n4: lda sprite_shift_y
    beq n2

    ; Draw lower right.
    inc scry
    jsr get_char
    lda d+1
    beq n2
    ldy sprite_shift_y
    dey
    lda sprite_data_bottom
    jmp blit_right

n2: rts
.)
