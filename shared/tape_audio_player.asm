    org $351

tape_audio_player:
    lda via_peripheral_ctrl ; Start motor.
    and #$fd
    sta via_peripheral_ctrl

    lda #0
    sta $912b
    lda #@(low (* 8 audio_longest_pulse))
    sta $9124
    lda #@(high (* 8 audio_longest_pulse))
    tay
    sta $9125

f:  lda $9121
l:  lda $912d
    lsr
    lsr
    bcc -l

    lda $9124
    sty $9125
    lsr
    lsr
    lsr
    sta vicreg_auxcol_volume
    sta vicreg_screencol_reverse_border
;    sta $1e00,x
;    inx

    jmp -f

;xlat: @(amplitude-conversions)
