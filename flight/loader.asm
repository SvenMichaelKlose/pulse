sample_buffer= $1a00

irq_break_delay = @(half 3)
irq_delay = 7
irq_handler_delay = 29
restart_delay = @(+ irq_break_delay irq_delay irq_handler_delay)

timer = @(- (* 8 radio_longest_pulse) restart_delay)

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

    lda #0
    sta tleft
    lda #<timer
    sta current_low
    jsr radio_start_data
    lda #<radio_detect
    sta $314
    lda #>radio_detect
    sta $315
    lda #%00000000      ; VIA1 T1 one-shot mode
    sta $912b
    lda #%10000010      ; CA1 enable (tape pulse)
    sta $912e
    cli
    rts

radio_start_data:
    lda #@(radio-data-size)
    sta dleft
    lda #16
    sta tape_leader_countdown
    lda #8
    sta tape_bit_counter
    lda #@(low *tape-pulse*)
    sta $9124
    lda #@(high *tape-pulse*)
    sta $9125
    rts

radio_play:
    lda $9124       ; Read the timer's low byte which is your sample.
    ldy #>timer
    sty $9125

    ; Clip sample.
    tax
    bpl +n
    cmp #196
    bcc +s
    lda #0
    beq +n
s:  lda #127

    ; Reduce sample from 7 to 4 bits and save it.
n:  lsr
    lsr
    lsr
    ldy tleft
    ora #@(* orange 16)
mod_sample_setter:
    sta sample_buffer,y

    ; Make sum of samples.
    txa
    clc
    adc average
    sta average
    bcc +n
    inc @(++ average)

n:  dec tleft
    bne return_from_interrupt

    ; Correct time if average pulse length doesn't match our desired value.
    lda @(++ average)   ; average / 256
    cmp #$3f
    beq +done           ; It's already what we want.
    bcc +n
    dec current_low
    bne +d
n:  inc current_low
d:  lda current_low
    sta $9124

done:
    lda #0
    sta average
    sta @(++ average)
    jsr radio_start_data
    lda #<radio_sync_data
    sta $314
    lda #>radio_sync_data
    sta $315
    jmp return_from_interrupt

radio_sync_data:
    inc chunks_loaded
    jsr radio_get_bit
    lda #<radio_load_data
    sta $314
    lda #>radio_load_data
    sta $315
    lda @(+ 2 mod_sample_setter)
    sta @(+ 2 mod_sample_getter)
    eor #1
    sta @(+ 2 mod_sample_setter)
    sta do_play_radio
    lda #0
    sta rr_sample
    jmp return_from_interrupt

radio_detect:
    jsr radio_get_bit
    bcc +n
    ldx #<radio_detect
    ldy #>radio_detect
    lda tape_leader_countdown
    bpl restart_loader
    ldx #<radio_load_data
    ldy #>radio_load_data
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

radio_load_data:
    jsr radio_get_bit
    ror tape_current_byte
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
    bne +n
    dec @(++ tape_counter)
    beq +done

n:  dec dleft
    bne return_from_interrupt

    lda #<radio_sync_audio
    sta $314
    lda #>radio_sync_audio
    sta $315
    lda current_low
    sta $9124
    lda #>timer
    sta $9125
    jmp return_from_interrupt

radio_sync_audio:
    inc chunks_loaded
    lda #<radio_play
    sta $314
    lda #>radio_play
    sta $315
    jmp return_from_interrupt

done:
    sei
    ldx #$ff
    txs
    lda #$7f
    sta $911b
    sta $911e
    sta $912d   ; Acknowledge tape pulse interrupt.
    sta $912e   ; Turn off tape pulse interrupt.

    ldx #0
    lda #8
l:  sta sample_buffer,x
    sta @(+ 256 sample_buffer),x
    dex
    bne -l
    jmp (tape_callback)
