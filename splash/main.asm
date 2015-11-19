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

    lda #48         ; 24 rows
    sta $9003
    lda #$fc        ; Character set at $1000.
    sta $9005

    ldx #0

    ; Characters to low memory.
l:  lda @(+ characters #x0000),x
    sta $0000,x
    lda @(+ characters #x0100),x
    sta $0100,x
    lda @(+ characters #x0200),x
    sta $0200,x
    lda @(+ characters #x0300),x
    sta $0300,x

    ; Copy area of chars 128-159 to unused color RAM.
    lda game_part,x
    sta $9400,x
    lsr
    lsr
    lsr
    lsr
    sta $9500,x

    ; Copy splash screen viewer and audio player benea
    cpx #@(++ (low (- relocated_splash_end relocated_splash)))
    bcs +n
    lda @(-- (+ loaded_splash 0)),x
    sta @(-- (+ relocated_splash 0)),x

    cpx #240
    bcs +n

    ; Copy screen data to screen.
    lda screen_data,x
    sta screen,x
    lda @(+ screen_data 240),x
    sta @(+ screen 240),x

    ; Copy colors to color RAM.
    lda color_data,x
    sta colors,x
    lda @(+ color_data 240),x
    sta @(+ colors 240),x

n:  inx
    bne -l

    ; Save parts that'll be destroyed by the loader.
    ; Also configure the loader.
    ldx #tape_leader_countdown
l:  lda $0,x
    sta saved_zeropage,x
    lda @(- #x200 tape_leader_countdown),x
    sta saved_stack,x
    lda loader_configuration,x
    sta tape_ptr,x
    dex
    bpl -l

    ; Boost digital audio.
    lda #$00
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

ws = @(+ characters (* 63 8))
we = @(+ ws 8)
characters:     @(fetch-file "obj/splash.chars.0-127.bin")
screen_data:    @(fetch-file "obj/splash.screen.bin")
color_data:     @(fetch-file "obj/splash.colors.bin")
game_part:      @(subseq (fetch-file *current-game*) 1024 (+ 1024 256))
