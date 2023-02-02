    ; Stop alto and soprano channel.
    lda #$7e
    sta $900b
    sta $900c

    ; Let them rest to get a regular wave form.
    ldy #0
l:  dey
    nop
    bne -l

    ; Start alto channel at highest frequency of
    ; ~8659Hz, which is 128 CPU cycles.
    lda #$fe
    sta $900b

    ; Waste 56 cycles.
    ; 2+10*5+4
    ldy #11     ; 2
l:  dey         ; 2
    bne -l      ; 3

    ; Waste missing 2 cycles.
    nop         ; 2

    ; Start soprano channel at same frequency as alto.
    ; Takes 6 cycles. Then it's exactly half a wave
    ; (512 cycles) apart from the alto.
    lda #$fd    ; 2
    sta $900c   ; 4
