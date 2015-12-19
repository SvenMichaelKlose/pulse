play_sample:
    ; Check if we need to play a sample.
    lda $911d           ; Get timer 1/VIA 1 underflow bit.
    asl                 ; Shift it into the M flag.
    bpl +done           ; Nothing to be played, yet…

    ; Reset timer.
    lda #>radio_timer
    sta $9115

    stx save_x
    ldx rr_sample
mod_sample_getter:
    lda sample_buffer,x
    sta $900e
    dex
    stx rr_sample
    ldx save_x
done:
    rts
