loaded_splash:
    org $1c70
relocated_splash:

splash:
    ; Restore areas that have been destroyed by the loader.
    ldx #$0f
l:  lda saved_zeropage,x
    sta $0000,x
    lda saved_stack,x
    sta $01f0,x
    dex
    bpl -l

    ldy #4
p:  ldx #0
l:  lda $1000,x
    sta tmp
m:  $bd $00 $00 ;lda $0000,x
n:  sta $1000,x
    lda tmp
o:  $9d $00 $00 ;sta $0000,x
    inx
    bne -l
    inc @(+ -l 2)
    inc @(+ -m 2)
    inc @(+ -n 2)
    inc @(+ -o 2)
    dey
    bne -p

    lda #150        ; Unblank screen.
    sta $9002
    lda #$fc        ; Character set at $1000.
    sta $9005
    lda #$09        ; Black screen
    sta $900f
