init_frame:
.(
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char
    inc framecounter
    bne n
    inc framecounter_high
n:  rts
.)

alloc_wrap:
    lda spriteframe
    ora #first_sprite_char
    jmp fetch_char

alloc_char:
    lda next_sprite_char
foregroundmask:
    and #foreground
foregroundtest:
    cmp #foreground
    beq alloc_wrap
    lda next_sprite_char
    inc next_sprite_char

fetch_char:
.(
    and charsetmask
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

get_char:
.(
    jsr test_position
    bcs cant_use_position
    jsr scrcoladdr
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
    sta (scr),y
    lda curcol
    sta (col),y
    rts
on_foreground:
    lda #1
    sta foreground_collision
cant_use_position:
    lda #$f0
    sta d+1
    rts
.)

reuse_char:
    lda curcol
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

clear_char:
.(
    jsr test_position
    bcs r
    jsr scraddr
    lda (scr),y
    and #foreground
    cmp #foreground
    beq r
    lda (scr),y
    beq r
    and #framemask
    cmp spriteframe
    beq r
    tya
    sta (scr),y
r:  rts
.)
