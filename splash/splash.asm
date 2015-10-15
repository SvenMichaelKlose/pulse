loaded_splash:
    org $1ca0

splash:
    ; Restore areas that have been destroyed by the loader.
    ldx #$0f
l:  lda saved_zeropage,x
    sta $0000,x
    lda saved_stack,x
    sta $01f0,x
    dex
    bpl -l

    lda #150
    sta $9002
    lda #8              ; (character set at $0000)
    sta $9005
    lda #8              : (black screen and border)
    sta $900f
