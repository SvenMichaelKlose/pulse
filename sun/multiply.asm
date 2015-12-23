multiply:
    stx save_x
    sty save_y

    lda result  ; Determine and save signedness of result.
    eor product
    sta tmp

    lda product
    jsr abs
    sta product

    jsr unsigned_multiply
    tya

    asl tmp
    bcc no_neg
    jsr neg_result

no_neg:
    ldx save_x
    ldy save_y
    rts

; Derived from http://codebase64.org/doku.php?id=base:8bit_multiplication_16bit_product
unsigned_multiply:
    lda #$00
    tay
    beq +start

add:clc
    adc result_decimals
    tax

    tya
    adc result
    tay
    txa

next_bit:
    asl result_decimals
    rol result
start:
    lsr product
    bcs -add
    bne -next_bit
    sta result_decimals
    sty result
    rts
