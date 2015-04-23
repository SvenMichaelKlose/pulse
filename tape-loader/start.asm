tape_loader_start:
    lda #<@*tape-loader-start*        ; Set IRQ vector.
    sta $314
    lda #>@*tape-loader-start*
    sta $315
    lda #@(low *tape-pulse*) ; Set half of timer.
    sta $9114

    lda $911c           ; Start motor.
    and #$fd
    sta $911c

    ldy #32             ; Give it time to start.
a:  ldx #0
l:  dex
    bne -l
    dey
    bne -a

    lda #11             ; First byte plus three false pulses.
    sta tape_bit_counter

    lda #%00000000      ; VIA1 T1 one-shot mode
    sta $911b
    lda #%10000010      ; CA1 enable (tape pulse)
    sta $912e
    lda #@(high *tape-pulse*) ; Start timer.
    sta $9115

    rts
