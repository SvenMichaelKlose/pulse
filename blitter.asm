blit_left_whole_char:
    ldy #8
blit_left:
.(
    dey
l1: lda (spr),y
    ldx sprshiftx
    beq s1
s2: lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
    dex
    beq s1
    lsr
s1: ora (d),y
    sta (d),y
    dey
    bpl l1
    rts
.)

blit_right_whole_char:
    ldy #8
blit_right:
.(
    dey
l1: lda (spr),y
    ldx sprshiftx
    beq s1
s2: asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
    dex
    beq s1
    asl
s1: ora (d),y
    sta (d),y
    dey
    bpl l1
    rts
.)

bzero:
.(
    sta c
    sty c+1
    ldy #0
l1: lda c
    bne l2
    lda c+1
    beq e1
    dec c+1
l2: dec c
w:  tya
    sta (d),y
    inc d
    bne l1
    inc d+1
    jmp l1
e1: rts
.)
