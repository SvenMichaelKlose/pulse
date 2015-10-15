; Leader of long pulses.
tape_loader:
    jsr tape_get_bit
    bcs +n
    lda tape_leader_countdown
    bpl restart_loader
    ldx #<tape_leader_shorts
    ldy #>tape_leader_shorts
next_leader:
    lda #128
    sta tape_leader_countdown
    jmp set_irq_vector
n:  dec tape_leader_countdown
    jmp return_from_interrupt

restart_loader:
    ldx #<tape_loader
    ldy #>tape_loader
    bne next_leader

; Leader of short pulses.
tape_leader_shorts:
    jsr tape_get_bit
    bcc -n
    lda tape_leader_countdown
    bpl restart_loader       ; Not enough pulses. Restart loading.
    lda #8
    sta tape_bit_counter
    ldx #<tape_loader_data
    ldy #>tape_loader_data
set_irq_vector:
    stx $314
    sty $315
    bne return_from_interrupt

; After one more long pulse the data begins.
tape_loader_data:
    jsr tape_get_bit
    ror tape_current_byte
;#ifdef IRQ_LOADER_EFFECT
    lda tape_current_byte
    sta vicreg_screencol_reverse_border
;#endif
    dec tape_bit_counter
    beq byte_complete
return_from_interrupt:
    pla
    tay
    pla
    tax
    pla
    rti

tape_get_bit:
    lda $911d               ; Get timer underflow bit.
    ldx #@(high *tape-pulse*) ; Restart timer.
    stx $9115
    ldx $9121
    inc $900f
    asl                     ; Get underflow bit.
    asl
    rts

byte_complete:
    lda #8                  ; Reset bit count.
    sta tape_bit_counter
    lda tape_current_byte   ; Save byte to its destination.
    ldy #0
    sta (tape_ptr),y
    inc tape_ptr            ; Advance destination address.
    bne +n
    inc @(++ tape_ptr)
n:  dec tape_counter        ; All bytes loaded?
    bne return_from_interrupt ; No...
    dec @(++ tape_counter)
    bne return_from_interrupt ; No...
    lda #$7f                ; Turn off tape pulse interrupt.
    sta $912e
    lda #0                  ; Stop motor.
    sta $911c
    sei
    lda tape_old_irq
    sta $314
    lda @(++ tape_old_irq)
    sta $315

    ldx #$f6
    txs
    lda #0
    sta $911c
    tax
    tay
    jmp (tape_callback)

loader_end:
