realstart   = $1000 + charsize

main:
    cli
    lda #$7f
    sta $912e     ; disable and acknowledge interrupts
    sta $912d
    sta $911e     ; disable NMIs (Restore key)

    ; Character 0 shall always be nothing.
.(
    ldx #$0f
    lda #0
l1: sta chars,x
    dex
    bpl l1
.)

    lda #%11111100  ; Our charset.
    sta $9005
    lda #8+blue       ; Screen and border.
    sta $900f
    lda #red*16     ; Auxiliary color.
    sta $900e

init_end:
    .dsb realstart-init_end, $ea
