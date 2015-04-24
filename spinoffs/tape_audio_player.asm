average_loop_cycles = @(half (+ 4 2 2 3))
timer = @(- (* 8 audio_longest_pulse) average_loop_cycles)

tape_audio_player:
    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ; Initialize VIA2 timer 1.
    lda #0      ; one-shot mode
    sta $912b
    lda #<timer ; countdown
    sta $9124
    ldy #>timer

    ; Play.
f:  lda $9121   ; (4) Reset the VIA2 CA1 status bit.
l:  lda $912d   ; (4) Reset the VIA2 CA1 status bit.
    lsr         ; (2) Shift to test bit 2.
    lsr         ; (2)
    bcc -l      ; (2/3) Nothing happened yet. Try again…

    lda $9124   ; (4) Read the timer's low byte which is your sample.
    sty $9125   ; (4) Write high byte to restart the timer.
    lsr         ; (2) Reduce sample from 7 to 4 bits.
    lsr         ; (2)
    lsr         ; (2)
    sta $900e   ; (4) Play it!
    sta $900f   ; (4) Something for the eye.

    jmp -f      ; (4)

;xlat: @(amplitude-conversions)
