reuse_char:
    lda curcol
    ldy scrx
    sta (col),y
    txa

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
    ora #>charset
    sta d+1
    rts

alloc_wrap:
    lda spriteframe
    ora #first_sprite_char
    jmp fetch_char

alloc_char:
    lda next_sprite_char
    and #foreground
    cmp #foreground
    beq alloc_wrap
    lda next_sprite_char
    inc next_sprite_char

fetch_char:
.(
    and #charsetmask
    pha
    jsr get_char_addr
    jsr blit_clear_char
    pla
    iny
    rts
.)

test_position:
.(
    lda scrx
    cmp #22
    bcs e
    lda scry
    cmp #23
e:  rts
.)

scraddr_get_char:
    jsr scrcoladdr

get_char:
.(
    jsr test_position
    bcs cant_use_position
    ldy scrx
    lda (scr),y
    beq l2
    tax
    and #foreground
    cmp #foreground
    beq on_foreground
    txa
    and #framemask
    cmp spriteframe
    beq reuse_char
l2: jsr alloc_char
    ldy scrx
    sta (scr),y
    lda curcol
    sta (col),y
    rts
on_foreground:
    inc foreground_collision
cant_use_position:
    lda #$f0
    sta d+1
    rts
.)

scraddr_clear_char:
    jsr scraddr

clear_char:
.(
    jsr test_position
    bcs r
    ldy scrx
    lda (scr),y
    and #foreground
    cmp #foreground
    beq r
    lda (scr),y
    beq r
    and #framemask
    cmp spriteframe
    beq r
    lda #0
    sta (scr),y
r:  rts
.)
