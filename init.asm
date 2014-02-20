realstart   = $1000 + charsetsize

main:
    cli
    lda #$7f
    sta $912e       ; disable and acknowledge interrupts
    sta $912d
    sta $911e       ; disable NMIs (Restore key)

.(
    ldx #0
l:  lda lowmem,x
    sta $200,x
    lda lowmem+$100,x
    sta $300,x
    dex
    bne l
.)

    jmp intro
