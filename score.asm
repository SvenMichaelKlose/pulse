increment_score:
    stx tmp
    sty tmp2

    ldx #7
    sec
l:  lda score_on_screen,x
    adc #0
    cmp #@(+ score_char0 10)
    bcc +l2
    cpx #5              ; +1 life every 1000 points.
    bne +l6
    inc lifes
    lda #15
    sta sound_bonus
l6: lda #score_char0
    sec
l2: sta score_on_screen,x
    dex
    bpl -l

    ; Compare score with hiscore.
    inx
    ldy #7
l3: lda score_on_screen,x
    cmp hiscore_on_screen,x
    beq +l4
    bcc +done

new_hiscore:
    ldx #7
l5: lda score_on_screen,x
    sta hiscore_on_screen,x
    lda #green
    sta @(+ (- hiscore_on_screen screen) colors),x
    dex
    bpl -l5
    bmi +done

l4: inx
    dey
    bpl -l3

done:
    ldx tmp
    ldy tmp2
    rts
