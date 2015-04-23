    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    lda #0
    sta vicreg_rasterlo_rows_charsize

    ; Copy loader into screen memory.
    ldx #@(++ (- waiter_end loader))
l:  lda @loaded_loader,x
    sta @loader,x
    dex
    bpl -l

    ; Configure the loader.
    ldx #6
l:  lda loader_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr @start_loader
    jmp @waiter

game_size = @(length (fetch-file "obj/game.bin"))

loader_cfg:
    @(low *game-start*)
    @(high *game-start*)
    <game_size
    @(++ >game_size)
    @(low run) @(high run)
