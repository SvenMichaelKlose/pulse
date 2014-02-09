blit_left_whole_char:
    ldy #7
blit_left:
.(
    sta s
l1: lda (s),y
    ldx sprshiftxl
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
    ldy #7
blit_right:
.(
    sta s
l1: lda (s),y
    ldx sprshiftxr
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
