waiter:
    jmp waiter
run:lda #46
    sta vicreg_rasterlo_rows_charsize
    jmp $1000
waiter_end:
