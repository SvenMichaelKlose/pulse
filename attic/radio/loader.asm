; Minus half of VIA CA1 status bit test loop cycles and instructions to reinit.
rom_irq_cycles = 29
restart_delay = 12
timer = @(- (* 8 *radio-pulse*) rom_irq_cycles restart_delay)

radio_start:
    ; Boost digital audio with distorted HF carrier.
    lda #$0f
    sta $900e
    ldx #$7e
    stx $900c
    ldy #0
l:  dey
    bne -l
    lda #$fe
    stx $900c
    stx $900c
    sta $900c
    sta $900c
    stx $900c
    sta $900c

    lda #<radio_loader
    sta $314
    lda #>radio_loader
    sta $315
    lda #16
    sta tape_leader_countdown
    lda #8
    sta tape_bit_counter
    lda #@(low *radio-pulse*) ; Set half of timer.
    sta $9124
    lda #@(high *radio-pulse*) ; Start timer.
    sta $9125
    lda #%00000000      ; VIA1 T1 one-shot mode
    sta $912b
    lda #%10000010      ; CA1 enable (tape pulse)
    sta $912e
    cli

    rts

radio_loader:
    jsr radio_get_bit
    bcc +n
    ldx #<radio_loader
    ldy #>radio_loader
    lda tape_leader_countdown
    bpl restart_loader
    ldx #<radio_audio_sample ;radio_loader_data
    ldy #>radio_audio_sample ;radio_loader_data
restart_loader:
    lda #16
    sta tape_leader_countdown
    stx $314
    sty $315
    bne return_from_interrupt
n:  dec tape_leader_countdown
return_from_interrupt:
    lda #$7f                ; Acknowledge tape pulse interrupt.
    sta $912d
    jmp $eb18

radio_get_bit:
    lda $912d               ; Get timer underflow bit.
    ldx #@(high *tape-pulse*) ; Restart timer.
    stx $9125
    ldx $9121
    asl     ; Move underflow bit into carry.
    asl
    rts

radio_audio_sample:
    lda $9124       ; Read the timer's low byte which is your sample.
    ldx $912d
    ldy #@(high *radio-pulse*)
    sty $9125
    tay
    txa
    asl
    asl
    tya
    bcc +n
    sbc #63
    jmp +m
n:  adc #63
m:  lsr             ; Reduce sample from 7 to 4 bits.
    lsr
    lsr
    sta $900e       ; Play it!
    sta $900f

radio_loader_data:
    txa
    asl
    ror tape_current_byte
    lda tape_current_byte
    dec tape_bit_counter
    bne return_from_interrupt

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
beq return_from_interrupt ; No...

    sei
    lda #$7f                ; Turn off tape pulse interrupt.
    sta $912e
    sta $912d

    jmp (tape_callback)
