increment_score:
    stx tmp
    sty tmp2

    ldx #@(-- num_score_digits)
    sec
l:  lda score_on_screen,x   ; Add carry to digit.
    adc #0
    cmp #@(+ score_char0 10)
    bcc +l2
    cpx #5              ; Another 1000 points complete?
    bne +l6
    inc lifes           ; +1 life
    lda #15
    sta sound_bonus
l6: lda #score_char0
    sec
l2: sta score_on_screen,x
    dex
    bpl -l

    ; Compare score with hiscore.
    inx
    ldy #@(-- num_score_digits)
l3: lda score_on_screen,x
    cmp hiscore_on_screen,x
    beq +l4
    bcc +done

    ; Copy score to highscore.
new_hiscore:
    ldx #@(-- num_score_digits)
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
