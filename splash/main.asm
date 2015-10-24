saved_zeropage  = $1df0
saved_stack     = $1de0
current_low     = $1ddb
average         = $1ddc
tleft           = $1dde
tmp             = $1ddf

    org $1000

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
    lda @(+ screen_data #x100),x
    sta @(+ screen #x100),x
    lda #$0b
    sta colors,x
    sta @(+ colors #x100),x
    inx
    bne -l

    ; Copy splash screen code someplace else.
    ldx #@(- relocated_splash_end relocated_splash)
l:  lda @(-- loaded_splash),x
    sta @(-- relocated_splash),x
    dex
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

    jmp tape_loader_start

game_size = @(length (fetch-file (+ "obj/game.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_configuration:
    $00 $10
    <game_size @(++ >game_size)
    <splash >splash
