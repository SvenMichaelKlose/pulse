saved_zeropage  = @(- #x1e00 tape_leader_countdown 1)
saved_stack     = @(- saved_zeropage tape_leader_countdown 1)
tmp             = @(- saved_stack 1)
tleft           = @(- tmp 1)
average         = @(- tleft 2)
current_low     = @(- average 1)

memory_end = current_low

    $02 $10
    org $1002

main:
    ldx #$ff
    txs

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
;    lda loaded_splash,x
;    sta relocated_splash,x
    lda game_part,x
    sta $9400,x
    lsr
    lsr
    lsr
    lsr
    sta $9500,x
    cpx #@(++ (low (- relocated_splash_end relocated_splash)))
    bcs +n
    lda @(-- (+ loaded_splash 0)),x
    sta @(-- (+ relocated_splash 0)),x
n:  inx
    bne -l

    ; Save parts that'll be destroyed by the loader.
    ; Also configure the loader.
    ldx #tape_leader_countdown
l:  lda $0,x
    sta saved_zeropage,x
    lda $01f0,x
    sta saved_stack,x
    lda loader_configuration,x
    sta tape_ptr,x
    dex
    bpl -l

    ; Boost digital audio.
    lda #$0f
    sta $900e
    ldx #$7e
    stx $900c
    ldy #0
l:  dey
    bne -l
    lda #$fe
    stx $900c
    stx $900c
    sta $900c
    sta $900c
    stx $900c
    sta $900c

    jmp tape_loader_start

game_size = @(length (fetch-file (+ "obj/game.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_configuration:
    $00 $10
    <game_size @(++ >game_size)
    <splash >splash

characters:     @(fetch-file "obj/splash.chars.0-127.bin")
screen_data:    @(fetch-file "obj/splash.screen.bin")
color_data:     @(fetch-file "obj/splash.colors.bin")
game_part:      @(subseq (fetch-file *current-game*) 1024 (+ 1024 256))
