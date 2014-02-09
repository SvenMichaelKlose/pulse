addedsprites: .byt 0

add_sprite:
.(
    txa
    pha
    ldx #15
l1: lda sprites_h,x
    bne l2
    lda sprite_inits,y
    sta sprites_x,x
    iny
    lda sprite_inits,y
    sta sprites_y,x
    iny
    lda sprite_inits,y
    sta sprites_i,x
    iny
    lda sprite_inits,y
    sta sprites_c,x
    iny
    lda sprite_inits,y
    sta sprites_l,x
    iny
    lda sprite_inits,y
    sta sprites_h,x
    iny
    lda sprite_inits,y
    sta sprites_fl,x
    iny
    lda sprite_inits,y
    sta sprites_fh,x
    pla
    tax
    inc addedsprites
    rts
l2: dex
    bpl l1
    pla
    tax
    rts
.)

remove_sprite:
    dec addedsprites
    lda #0
    sta sprites_h,x
    rts

sprite_up:
.(
    lda sprites_y,x
    beq e1
    dec sprites_y,x
e1: rts
.)

sprite_down:
.(
    lda sprites_y,x
    cmp #22*8
    bcs e1
    inc sprites_y,x
e1: rts
.)

sprite_left:
.(
    lda sprites_x,x
    beq e1
    dec sprites_x,x
e1: rts
.)

sprite_right:
.(
    lda sprites_x,x
    cmp #21*8
    bcs e1
    inc sprites_x,x
e1: rts
.)

find_hit:
.(
    txa
    pha
    stx tmp
    ldy #numsprites-1
l1: cpy tmp
    beq n1
    lda sprites_h,y
    beq n1

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
l1: lda sprites_h,x     ; Skip unallocated sprites.
    beq n1

    sta s+1
    lda sprites_l,x
    sta s

#ifdef TIMING
    txa
    and #7
    ora #8
    sta $900f
#endif

    txa
    pha
    jsr draw_sprite
    pla
    tax

n1: inx
    cpx #numsprites
    bne l1
.)

    ; Remove leftover chars.
.(
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
n2: lda sprites_h,x
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

    inc framecounter
    rts

; Draw a single sprite.
draw_sprite:
.(
    lda s
    sta spr_u

    lda sprites_c,x
    sta curcol

    ; Get position on screen.
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

    ; Get shifts
    lda sprites_x,x
    and #%111
    sta sprshiftxl
    lda #8
    sec
    sbc sprshiftxl
    sta sprshiftxr
    lda sprites_y,x
    and #%111
    sta sprshifty

    ; Draw upper left.
    jsr get_char
    lda d
    clc
    adc sprshifty
    sta d
    lda #8
    sec
    sbc sprshifty
    sta counter_u
    tay
    lda d+1
    beq n3
    lda spr_u
    jsr blit_left

n3: lda sprshifty       ; No lower half to draw...
    beq n1

    ; Draw lower left.
    inc scry            ; Prepare next line.
    jsr get_char
    lda s
    clc
    adc counter_u
    sta spr_l
    lda d+1
    beq n6
    lda spr_l
    ldy sprshifty
    dey
    jsr blit_left
n6: dec scry

n1: lda sprshiftxl      ; No right halves to draw...
    beq n2

    ; Draw upper right.
    inc scrx            ; Prepare next line.
    jsr get_char
    lda d+1
    beq n4
    lda d
    clc
    adc sprshifty
    sta d
    ldy counter_u
    lda spr_u
    jsr blit_right

n4: lda sprshifty       ; No lower half to draw...
    beq n2

    ; Draw lower right.
    inc scry
    jsr get_char
    lda d+1
    beq n2
    ldy sprshifty
    dey
    lda spr_l
    jmp blit_right

n2: rts
.)
