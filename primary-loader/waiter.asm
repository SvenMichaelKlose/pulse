waiter:
    jmp waiter
run:
    lda #46
    sta vicreg_rasterlo_rows_charsize
    jmp $100d
waiter_end:
