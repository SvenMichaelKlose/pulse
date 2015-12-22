load_8k:
    ; Init sample playing and halt until first buffer has been loaded.
    lda #0
    sta rr_sample
    sta do_play_radio

    ; Load +8K block.
    ldy #<loader_cfg_8k
    lda #>loader_cfg_8k

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

init_8k:
    ; Set patch vector called by game.
    lda model
    lsr
    beq +n
    jsr $2002
n:

    ; Load +16K block.
    ldy #<loader_cfg_16k
    lda #>loader_cfg_16k
    jmp do_flight

init_16k:
    ; Load +24K block.
    ldy #<loader_cfg_24k
    lda #>loader_cfg_24k
    jmp do_flight

init_24k:
    ; Load +32K block.
    ldy #<loader_cfg_32k
    lda #>loader_cfg_32k
    jmp do_flight

init_32k:
    ; Blank screen.
    lda #0
    sta $9002

    ; Load splash screen.
    ldx #5
l:  lda loader_cfg_splash,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start

patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))
patch_16k_size = patch_8k_size
patch_24k_size = patch_8k_size
patch_32k_size = patch_8k_size
splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_8k:
    $00 $20
    <patch_8k_size @(++ >patch_8k_size)
    <init_8k >init_8k

loader_cfg_16k:
    $00 $40
    <patch_16k_size @(++ >patch_16k_size)
    <init_16k >init_16k

loader_cfg_24k:
    $00 $60
    <patch_24k_size @(++ >patch_24k_size)
    <init_24k >init_24k

loader_cfg_32k:
    $00 $a0
    <patch_32k_size @(++ >patch_32k_size)
    <init_32k >init_32k

loader_cfg_splash:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10
