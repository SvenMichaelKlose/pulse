loaded_tape_loader:                                                             
    org @*tape-loader-start*

tape_loader_start:
    lda $314
    sta tape_old_irq
    lda $315
    sta @(++ tape_old_irq)
    lda #<tape_loader   ; Set IRQ vector.
    sta $314
    lda #>tape_loader
    sta $315
    lda #@(low *tape-pulse*) ; Set half of timer.
    sta $9114
    lda #128
    sta tape_leader_countdown

    lda $911c           ; Start motor.
    and #$fd
    sta $911c

    lda #%00000000      ; VIA1 T1 one-shot mode
    sta $911b
    lda #%10000010      ; CA1 enable (tape pulse)
    sta $912e
    lda #@(high *tape-pulse*) ; Start timer.
    sta $9115
    cli

w:  jmp w
