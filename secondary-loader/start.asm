tape_loader_start:
    lda $314            ; Save old IRQ vector.
    sta tape_old_irq
    lda $315
    sta @(++ tape_old_irq)
    lda #@(low *tape-loader-start*)   ; Set IRQ vector.
    sta $314
    lda #@(high *tape-loader-start*)
    sta $315
    lda #16
    sta tape_leader_countdown
    lda #8
    sta tape_bit_counter
    lda #@(low *tape-pulse*) ; Set half of timer.
    sta $9124
    lda #@(high *tape-pulse*) ; Start timer.
    sta $9125
    lda #%00000000      ; VIA1 T1 one-shot mode
    sta $912b
    lda #%10000010      ; CA1 enable (tape pulse)
    sta $912e

    ; Make endless loop.
    lda #$4c
    sta $1ffd
    lda #$fd
    sta $1ffe
    lda #$1f
    sta $1fff

    cli
    jmp $1ffd
