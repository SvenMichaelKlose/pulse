increment_score:
    stx tmp
    sty tmp2

    ldx #@(-- num_score_digits)
    sec
l:  lda score_on_screen,x   ; Add carry to digit.
    adc #0
    cmp #@(+ score_char0 10)
    bcc +n
    cpx #5              ; Another 1000 points complete?
    bne no_1up
    inc lifes           ; +1 life
    lda #15
    sta sound_bonus
no_1up:
    lda #score_char0
    sec
n:  sta score_on_screen,x
    dex
    bpl -l

    ; Compare score with hiscore.
    inx
    ldy #@(-- num_score_digits)
loop:
    lda score_on_screen,x
    cmp hiscore_on_screen,x
    beq +next
    bcc +done

    ; Copy score to highscore.
new_hiscore:
    ldx #@(-- num_score_digits)
l:  lda score_on_screen,x
    sta hiscore_on_screen,x
    lda #green
    sta @(+ (- hiscore_on_screen screen) colors),x
    dex
    bpl -l

next:
    inx
    dey
    bpl -loop

done:
    ldx tmp
    ldy tmp2
    rts
