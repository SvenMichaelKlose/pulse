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
