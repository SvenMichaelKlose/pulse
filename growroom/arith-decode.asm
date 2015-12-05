unsigned int high = 0xFFFFFFFFU;
unsigned int low = 0;
unsigned int value = 0;

    ldx #8
l:  jsr get_bit
    ror value
    dex
    bne -l

loop:
    ; unsigned int range = high - low + 1;
    lda high
    sec
    sbc low
    adc #0
    sta range

    ; unsigned int count =  ((value - low + 1) * m_model.getCount() - 1 ) / range;
    lda value
    sec
    sbc low
    adc #0
    sta multiplier
    jsr getcount
    dec result
    lda range
    sta divisor
    jsr divide
    lda result
    sta count
    
    ; prob p = m_model.getChar( count, c );
    jsr getchar
    bcs +done
    tax

    jsr byte_out

    ; high = low + (range*p.high)/p.count -1;
    lda p_high,x
    sta result
    lda range
    jsr multiply
    lda p_count
    jsr divide
    clc
    adc low
    sec
    sbc #1
    sta high

    ; low = low + (range*p.low)/p.count;
    lda p_high,x
    sta result
    lda range
    jsr multiply
    lda p_count
    jsr divide
    clc
    adc low
    sta high

    ;if ( low >= 0x80000000U || high < 0x80000000U ) {
l:  lda low
    bmi +g
    lda high
    bmi +n
g:

    lsr low
    lda high
    lsr
    ora #1
    sta high

    ; value += m_input.get_bit() ? 1 : 0;
update_value:
    jsr get_bit
    lda #0
    ror
    clc
    adc value
    sta value
    jmp -l

    ;  else if ( low >= 0x40000000 && high < 0xC0000000U ) {
n:  lda low
    cmp #$40
    bcc -loop
    lda high
    cmp #$c0
    bcs -loop
    lda low
    lsr
    and #$7f
    sta low
    lda high
    lsr
    ora #$81
    jmp update_value

get_bit:
    dec read_bits
    bne +n
r:  lsr input_byte
    rts
n:  lda #8
    sta read_bits
    ldy slow
    lda (s),y
    sta input_byte
    iny
    sty slow
    bne -r
    inc @(++ s)
    jmp -r
