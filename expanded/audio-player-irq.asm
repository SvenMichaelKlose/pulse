irq_break_delay = @(half 3)
irq_delay = 7
irq_handler_delay = 29
restart_delay = @(+ irq_break_delay irq_delay irq_handler_delay)

timer = @(- (* 8 (audio-longest-pulse)) restart_delay)

start_tape_audio:
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

    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ; Set IRQ vector.
    sei
    lda $314
    sta old_irq
    lda $315
    sta @(++ old_irq)
    lda #<play_audio_sample
    sta $314
    lda #>play_audio_sample
    sta $315

    ; Initialise VIA2 Timer 1 (cassette tape read).
    lda #<timer
    sta current_low
    sta $9124
    lda #>timer
    sta $9125

    lda #%00000000  ; One-shot mode.
    sta $912b
    lda #%10000010  ; CA1 IRQ enable (tape pulse)
    sta $912e

    ; Let the IRQ handler do everthing.
    cli
    rts

stop_tape_audio:
    ; Stop tape motor.
    lda $911c
    ora #2
    sta $911c

    sei
    lda old_irq
    sta $314
    lda @(++ old_irq)
    sta $315
    cli
    rts

play_audio_sample:
    lda $9124       ; Read the timer's low byte which is your sample.
    ldy #>timer
    sty $9125       ; Write high byte to restart the timer.

    ; Clip sample.
    tax
    bpl +n
    cmp #196
    bcc +s
    lda #0
    beq +n
s:  lda #127

n:  lsr             ; Reduce sample from 7 to 4 bits.
    lsr
    lsr
    sta $900e       ; Play it!
if @*nipkow-fx-border?*
    sta $900f       ; Something for the eye.
end

    ; Make sum of samples.
    txa
    clc
    adc average
    sta average
    bcc +n
    inc @(++ average)

n:  dec tleft
    bne +done

    ; Correct time if average pulse length doesn't match our desired value.
    lda @(++ average)   ; average / 256
    cmp #$3f
    beq +done           ; It's already what we want.
    tax
    bcc +n
    dec current_low
    bne +d
n:  inc current_low
d:  lda current_low
    sta $9124
    lda #0
    sta average
    sta @(++ average)

done:
    lda #$7f
    sta $912d
    jmp $eb18
