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
    ldx radius
    lda xlat_aspect,x
    sta result_decimals
    lda #0
    sta result
    lda degrees
    jsr sinmul
    tax

    lda radius
    sta result_decimals
    lda #0
    sta result
    lda degrees
    jsr cosmul
    tay

    rts

xlat_aspect:
    @(maptimes [integer (/ (* _ 3) 5)] (* 4 screen_columns))
