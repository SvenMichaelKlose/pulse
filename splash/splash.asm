loaded_splash:
    org $1d00

splash:
    ; Restore areas that have been destroyed by the loader.
    ldx #$0f
l:  lda saved_zeropage,x
    sta $0000,x
    lda saved_stack,x
    sta $01f0,x
    lda saved_irq,x
    sta $0310,x
    dex
    bpl -l

    lda #10             ; (horizontal origin)
    sta $9000
    lda #50             ; (vertical origin)
    sta $9001
    lda #@(+ 128 20)    ; (16 screen rows)
    sta $9002
    lda #@(* 16 12);    ; (16 screen columns)
    sta $9003
    lda #$fd            ; (character set at $1400)
    sta $9005
    lda #8              : (black screen and border)
    sta $900f
