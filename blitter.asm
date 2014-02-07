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
