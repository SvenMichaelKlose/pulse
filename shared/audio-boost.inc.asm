    ; Boost digital audio.
    lda #$00
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
