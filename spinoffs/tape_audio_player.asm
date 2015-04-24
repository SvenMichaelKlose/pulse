average_loop_cycles = @(half (+ 4 2 2 3))
timer = @(- (* 8 audio_longest_pulse) average_loop_cycles)

tape_audio_player:
    ; Start tape motor.
    lda via_peripheral_ctrl
    and #$fd
    sta via_peripheral_ctrl

    ; Initialize VIA2 T1 timing and one-shot mode.
    lda #0
    sta $912b
    lda #<timer
    sta $9124
    ldy #>timer

    ; Play.
f:  lda $9121   ; Reset the VIA2 CA1 status bit.
l:  lda $912d   ; (4) Reset the VIA2 CA1 status bit.
    lsr         ; (2) Shift to test bit 2.
    lsr         ; (2)
    bcc -l      ; (3) Nothing happened yet. Try again…

    lda $9124   ; Read the timer's low byte which is your sample.
    sty $9125   ; Write high byte to restart the timer.
    lsr         ; Reduce sample from 7 to 4 bits.
    lsr
    lsr
    sta vicreg_auxcol_volume    ; Play it!
    sta vicreg_screencol_reverse_border ; Something for the eye.

    jmp -f

;xlat: @(amplitude-conversions)
