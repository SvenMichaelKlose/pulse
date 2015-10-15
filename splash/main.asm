saved_zeropage  = $1df0
saved_stack     = $1de0
saved_irq       = $1dd0
current_low     = $1dcf
average         = $1dcd
tleft           = $1dcc

main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    ; Copy splash screen data.
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
    sta $1e00,x
    lda color_data,x
    sta $9600,x
    lda loaded_splash,x
    sta splash,x
    inx
    bne -l

    ; Save parts that'll be destroyed by the loader.
    ; Also configure the loader.
    ldx #$0f
l:  lda $0,x
    sta saved_zeropage,x
    lda $01f0,x
    sta saved_stack,x
    lda $0310,x
    sta saved_irq,x
    lda loader_configuration,x
    sta tape_ptr,x
    dex
    bpl -l

    jmp $1f00 ;@tape_loader_start

game_size = @(length (fetch-file (+ "obj/game.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_configuration:
    $ff $0f
    <game_size @(++ >game_size)
    @(low splash) @(high splash)
