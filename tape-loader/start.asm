loaded_tape_loader:                                                             
    org @*tape-loader-start*

tape_loader_start:
    lda $314            ; Save old IRQ vector.
    sta tape_old_irq
    lda $315
    sta @(++ tape_old_irq)
    lda #<tape_loader   ; Set IRQ vector.
    sta $314
    lda #>tape_loader
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
    cli

w:  jmp -w
