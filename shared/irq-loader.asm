loaded_loader:
    org $1e00

loader:
    lda $911d               ; Get timer underflow bit.
    ldx #@(high *tape-pulse*) ; Restart timer.
    stx $9115
    ldx $9121
    asl                     ; Roll underflow bit into our byte.
    asl
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
    jmp (tape_callback)

loader_end:
