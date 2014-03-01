increment_score:
.(
    stx tmp
    sty tmp2

    ldx #7
    sec
l:  lda score_addr,x
    adc #0
    cmp #58
    bcc l2
    lda #48
    sec
l2: sta score_addr,x
    dex
    bpl l

    ldx #0
    ldy #7
l3: lda score_addr,x
    cmp hiscore_addr,x
    beq l4
    bcc done

new_hiscore:
    ldx #8
l5: lda score_addr,x
    sta hiscore_addr,x
    lda #green
    sta hiscore_addr-screen+colors,x
    dex
    bpl l5
    bmi done

l4: inx
    dey
    bpl l3

done:
    ldx tmp
    ldy tmp2
    rts
.)
