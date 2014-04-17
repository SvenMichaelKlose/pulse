add_sprite:
.(
    stx tmp
    sty tmp2
    ldx #numsprites-1   ; Look for free slot.
l1: lda sprites_fh,x
    beq l2
    dex
    bpl l1
    ldx #numsprites-1   ; None available. Look for decorative sprite.
l4: lda sprites_i,x
    and #decorative
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
    adc #numsprites
    sta selfmod+1
    jmp l3
done:
    ldx tmp
    ldy tmp2
    rts
.)

remove_sprite:
    lda #0
    sta sprites_fh,x
    jmp add_star

sprite_up:
    jsr neg

sprite_down:
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts

sprite_left:
    jsr neg

sprite_right:
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts

test_sprite_out:
.(
    lda sprites_x,x
    cmp #$f9
    bcs c2
    cmp #22*8
    bcs c1
    lda sprites_y,x
    cmp #$f9
    bcs c2
    cmp #23*8
c1: rts
c2: clc
    rts
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
    and #decorative
    bne n1

    lda sprites_x,x     ; Get X distance.
    sec
    sbc sprites_x,y
    jsr abs
    cmp #8
    bcs n1
    lda #8
    sta collision_y_distance
    lda sprites_i,y
    cmp #deadly+2
    bne b1
    dec collision_y_distance
    dec collision_y_distance
b1: lda sprites_y,x     ; Get Y distance.
    sec
    sbc sprites_y,y
    jsr abs
    cmp collision_y_distance
    bcc c1
n1: dey
    bpl l1
    sec
c1: pla
    tax
    rts
.)

; Draw all sprites.
draw_sprites:
.(
    ; Draw decorative sprites.
    ldx #numsprites-1
l2: lda sprites_fh,x
    beq n3
    lda sprites_i,x
    and #decorative
    beq n3
    jsr draw_sprite
n3: dex
    bpl l2

    ; Draw other sprites.
    ldx #numsprites-1
l1: lda sprites_fh,x
    beq n1
    lda sprites_i,x
    and #decorative
    bne n1

    lda #0
    sta foreground_collision
    jsr draw_sprite

    ; Save foreground collision.
    lda sprites_i,x
    and #%01111111
    ldy foreground_collision
    beq n2
    ora #128
n2: sta sprites_i,x

n1: dex
    bpl l1
.)

; Remove remaining chars of sprites in old frame.
clean_screen:
.(
    ldx #numsprites-1
l1: lda sprites_ox,x
    cmp #$ff
    beq n2
    sta scrx
    lda sprites_oy,x
    sta scry
    jsr scraddr_clear_char
    inc scrx
    jsr clear_char
    dec scrx
    inc scry
    jsr scraddr_clear_char
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
    rts

; Draw a single sprite.
draw_sprite:
.(
    txa
    pha
    lda #>sprite_gfx
    sta s+1
    lda sprites_l,x
    sta s
    sta sprite_data_top

    lda sprites_c,x
    sta curcol

    ; Calculate text position.
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

    ; Configure the blitter.
    lda sprites_x,x
    and #%111
    tay
    sta blit_right_addr+1
    lda negate7,y
    sta blit_left_addr+1

    lda sprites_y,x
    and #%111
    sta sprite_shift_y
    tay
    lda negate7,y
    sta sprite_height_top

    ; Draw upper left.
    jsr scraddr_get_char
    lda d
    clc
    adc sprite_shift_y
    sta d
    lda sprite_data_top
    ldy sprite_height_top
    jsr blit_left

    lda blit_right_addr+1
    beq n2

    ; Draw upper right.
    inc scrx
    jsr get_char
    lda d
    clc
    adc sprite_shift_y
    sta d
    lda sprite_data_top
    ldy sprite_height_top
    jsr blit_right
    dec scrx

n2: lda sprite_shift_y
    beq n1

    ; Draw lower left.
    inc scry
    jsr scraddr_get_char
    lda s
    sec
    adc sprite_height_top
    sta sprite_data_bottom
    ldy sprite_shift_y
    dey
    jsr blit_left

    lda sprite_shift_y
    beq n1

    ; Draw lower right.
    inc scrx
    jsr get_char
    lda sprite_data_bottom
    ldy sprite_shift_y
    dey
    jsr blit_right

n1: pla
    tax
    rts
.)
