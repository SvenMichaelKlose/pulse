saved_zeropage  = $1df0
saved_stack     = $1de0
current_low     = $1ddb
average         = $1ddc
tleft           = $1dde
tmp             = $1ddf

main:
    ; Copy splash screen data to where the game won't load to.
    ldx #0
l:  lda @(+ characters #x0000),x
    sta $0000,x
    lda @(+ characters #x0100),x
    sta $0100,x
    lda @(+ characters #x0200),x
    sta $0200,x
    lda @(+ characters #x0300),x
    sta $0300,x
    lda screen_data,x
    sta screen,x
    lda #$0b
    sta colors,x
    sta @(+ colors #x100),x
    lda loaded_splash,x
    sta relocated_splash,x
    inx
    bne -l

    ; Save parts that'll be destroyed by the loader.
    ; Also configure the loader.
    ldx #$0f
l:  lda $0,x
    sta saved_zeropage,x
    lda $01f0,x
    sta saved_stack,x
    lda loader_configuration,x
    sta tape_ptr,x
    dex
    bpl -l

    jmp @*tape-loader-start*

game_size = @(length (fetch-file (+ "obj/game.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_configuration:
    $ff $0f
    <game_size @(++ >game_size)
    <splash >splash
