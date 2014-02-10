alloc_squeeze:
    lda spriteframe
    ora #first_sprite_char
    jmp fetch_char

alloc_char:
.(
    lda next_sprite_char
    tax
    and #foreground
    cmp #foreground
    beq alloc_squeeze
    txa
    inc next_sprite_char
.)

fetch_char:
.(
    and #charsetmask
    pha
    jsr get_char_addr
    lda #0          ; Clear the new char.
    ldy #7
l3: sta (d),y
    dey
    bpl l3
    pla
    rts
.)

test_position:
.(
    lda scrx
    bmi i
    cmp #22
    bcs i
    lda scry
    bmi i
    cmp #23
    bcs i
    clc
    rts
i:  stc
    rts
.)

get_char:
.(
    jsr test_position
    bcs fake_addr
    jsr scrcoladdr
    ldy #0
    lda (scr),y
    beq l2
    tax
    and #foreground
    cmp #foreground
    beq fake_addr
    txa
    and #framemask
    cmp spriteframe
    beq get_char_addrx
l2: jsr alloc_char
    ldy #0
    sta (scr),y
    lda curcol
    sta (col),y
    rts

fake_addr:
    lda #0
    sta d+1
    rts
.)

get_char_addrx:
    txa

    ; Get char address.
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

; Remove char if it's not in the current bank.
clear_char:
.(
    jsr test_position
    bcs e1
    jsr scraddr
    ldy #0
    lda (scr),y
    and #foreground
    cmp #foreground
    beq e1
    lda (scr),y
    beq e1
    and #framemask
    cmp spriteframe
    beq e1
    tya
    sta (scr),y
e1: rts
.)
