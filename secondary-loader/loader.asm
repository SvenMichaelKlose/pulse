loaded_tape_loader:
    org @*tape-loader-start*

tape_loader:
    jsr tape_get_bit
    bcc +n
    ldx #<tape_loader
    ldy #>tape_loader
    lda tape_leader_countdown
    bpl restart_loader
    ldx #<tape_loader_data ;leader_long
    ldy #>tape_loader_data ;leader_long
restart_loader:
    lda #64
    sta tape_leader_countdown
    stx $314
    sty $315
    bne return_from_interrupt
n:  dec tape_leader_countdown
    jmp return_from_interrupt

tape_loader_data:
    jsr tape_get_bit
    ror tape_current_byte
    dec tape_bit_counter
    beq byte_complete
return_from_interrupt:
    lda #$7f                ; Acknowledge tape pulse interrupt.
    sta $912d
    jmp $eb18

tape_get_bit:
    lda $912d               ; Get timer underflow bit.
    ldx #@(high *tape-pulse*) ; Restart timer.
    stx $9125
    ldx $9121
    asl     ; Move underflow bit into carry.
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

    sei
    lda #$7f                ; Turn off tape pulse interrupt.
    sta $912e
    sta $912d

    lda tape_old_irq
    sta $314
    lda @(++ tape_old_irq)
    sta $315

    jmp (tape_callback)

loader_end:
