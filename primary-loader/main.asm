main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    ; Blank screen.
;    lda #0
;    sta vicreg_rasterlo_rows_charsize

    ; Copy loader someplace else.
    ldx #0
l:  lda loaded_tape_loader,x
    sta @*tape-loader-start*,x
    lda loader_cfg,x
    sta tape_ptr,x
    inx
    bne -l

    jmp @*tape-loader-start*

splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg:
    $ff $0f
    <splash_size @(++ >splash_size)
    $0d $10
