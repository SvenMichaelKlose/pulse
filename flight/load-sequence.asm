load_8k:
    ; Init sample playing and halt until first buffer has been loaded.
    lda #0
    sta rr_sample
    sta do_play_radio

    ; Load +16K block.
    ldy #<loader_cfg_16k
    lda #>loader_cfg_16k

do_flight:
    sty @(+ 1 +l)
    sta @(+ 2 +l)
    ldx #5
l:  lda $ffff,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

load_splash:
    ; Blank screen.
    lda #0
    sta $9002

    ; Load splash screen.
    ldy #<loader_cfg_splash
    lda #>loader_cfg_splash
    jmp tape_loader_start

patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))
patch_16k_size = @(length (fetch-file (+ "obj/16k.crunched." (downcase (symbol-name *tv*)) ".prg")))
splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_16k:
    $00 $40
    <patch_16k_size @(++ >patch_16k_size)
    <load_splash >load_splash

loader_cfg_splash:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10
