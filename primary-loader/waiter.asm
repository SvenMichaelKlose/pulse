waiter:
    jmp waiter
run:
    ldx #253
l:  lda #32
    sta @(-- screen),x
    sta @(+ screen 252),x
    lda #black
    sta @(-- colors),x
    sta @(+ colors 252),x
    dex
    bne -l

    lda #46
    sta vicreg_rasterlo_rows_charsize
    ldx #$f6
    txs
    lda #0
    tax
    tay
    cli
    jmp $100d
waiter_end:
