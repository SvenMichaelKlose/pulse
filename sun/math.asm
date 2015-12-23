abs:ora #0
    bpl abs_end
neg:eor #$ff
    clc
    adc #1
abs_end:
    rts

neg_result:
    lda result
    eor #$ff
    sta result
    lda result_decimals
    eor #$ff
    sta result_decimals
    inc result_decimals
    bne +done
    inc result
done:
    rts

cosmul:
    sec
    sbc #64
sinmul:
    jsr sin
    sta product
    jmp multiply

point_on_circle:
    lda radius
    sta result_decimals
    lda #0
    sta result
    lda degrees
    jsr sinmul
    lda xpos
    clc
    adc result
    tax

    lda radius
    sta result_decimals
    lda #0
    sta result
    lda degrees
    jsr cosmul
    lda ypos
    clc
    adc result
    tay

    rts
