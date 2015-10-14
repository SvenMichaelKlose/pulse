main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    ; Blank screen.
    lda #0
    sta vicreg_rasterlo_rows_charsize

loader_size = @(- waiter_end *tape-loader-start* 1)
loader_high_offset = @(* 256 (high loader_size))

    ; Copy loader someplace else.
    ldx #@(low loader_size)
    ldy #@(high loader_size)
l:  lda loaded_tape_loader,x
l:  lda @(+ loader_high_offset loaded_tape_loader),x
m:  sta @(+ loader_high_offset *tape-loader-start*),x
    dex
    cpx #$ff
    bne -l
    dec @(+ 2 -l)
    dec @(+ 2 -m)
    dey
    bpl -l

    ; Configure the loader.
    ldx #6
l:  lda loader_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr @tape_loader_start
    jmp @waiter

game_size = @(length (fetch-file (+ "obj/game.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg:
    $ff $0f
    <game_size @(++ >game_size)
    @(low start_player) @(high start_player)

start_player:
    lda #8
    sta $900f
    lda #46
    sta vicreg_rasterlo_rows_charsize
    jmp tape_audio_player
