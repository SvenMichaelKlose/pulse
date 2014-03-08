increment_score:
.(
    stx tmp
    sty tmp2

    ldx #7
    sec
l:  lda score_on_screen,x
    adc #0
    cmp #58
    bcc l2
    cpx #5              ; +1 life every 1000 points.
    bne l6
    inc lifes
l6: lda #48
    sec
l2: sta score_on_screen,x
    dex
    bpl l

    ldx #0
    ldy #7
l3: lda score_on_screen,x
    cmp hiscore_on_screen,x
    beq l4
    bcc done

new_hiscore:
    ldx #7
l5: lda score_on_screen,x
    sta hiscore_on_screen,x
    lda #green
    sta hiscore_on_screen-screen+colors,x
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
