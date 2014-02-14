addedsprites: .byt 0

add_sprite:
.(
    txa
    pha
    ldx #numsprites-1
l1: lda sprites_fh,x
    beq l2
    dex
    bpl l1
    ldx #numsprites-1
l4: lda sprites_i,x
    and #32
    bne l2
    dex
    bpl l4
    pla
    tax
    rts
l2: lda #sprites_x
    sta sm+1
l3: lda sprite_inits,y
sm: sta sprites_x,x
    iny
    lda sm+1
    cmp #sprites_fh
    beq done
    clc
    adc #$10
    sta sm+1
    jmp l3
done:
    inc addedsprites
    pla
    tax
    rts
.)

remove_sprite:
    dec addedsprites
    lda #0
    sta sprites_fh,x
    jmp readd_star

sprite_up:
.(
    eor #$ff
    clc
    adc #1
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts
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
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts
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
    sec
    sbc #8
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
    ldx #0
l2: lda sprites_fh,x     ; Skip free slots.
    beq n3
    lda sprites_i,x
    and #32
    beq n3
    txa
    pha
    jsr draw_sprite
    pla
    tax
n3: inx
    cpx #numsprites
    bne l2

    ldx #0
l1: lda sprites_fh,x     ; Skip free slots.
    beq n1
    lda sprites_i,x
    and #32
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
    lda sprites_i,x
    and #%01111111
    ldy foreground_collision
    beq n2
    ora #128
n2: sta sprites_i,x
n1: inx
    cpx #numsprites
    bne l1
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
    jsr blit_left

n3: lda sprite_shift_y       ; No lower half to draw...
    beq n1

    ; Draw lower left.
    inc scry            ; Prepare next line.
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

n1: lda blitter_shift_left      ; No right halves to draw...
    beq n2

    ; Draw upper right.
    inc scrx            ; Prepare next line.
    jsr get_char
    lda d+1
    beq n4
    lda d
    clc
    adc sprite_shift_y
    sta d
    ldy sprite_height_top
    lda sprite_data_top
    jsr blit_right

n4: lda sprite_shift_y       ; No lower half to draw...
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
