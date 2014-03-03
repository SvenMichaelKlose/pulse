realstart   = $1000 + charsetsize

main:
    cli
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

init_lowmem:
.(
    ldx #0
l:  lda lowmem,x
    sta $200,x
    lda lowmem+$100,x
    sta $300,x
    dex
    bne l
.)

init_stackmem:
.(
    ldx #$60
l:  lda stackmem,x
    sta $180,x
    dex
    bpl l
.)

    jmp intro
