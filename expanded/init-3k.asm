;    $02 $10
    org $1000

    ldx #0
l:  lda loaded_patch3k,x
    sta patch3k,x
    lda @(+ #x100 loaded_patch3k),x
    sta @(+ #x100 patch3k),x
    dex
    bne -l

    lda #<post_patch
    sta model_patch
    lda #>post_patch
    sta @(++ model_patch)

    ; Check if there's only +3K RAM.
    lda model
    beq load_8k
    lsr
    bne load_8k
    bcc load_8k

    ; Set patch vector called by game.
    lda #<patch3k
    sta model_patch
    lda #>patch3k
    sta @(++ model_patch)

load_8k:
    ldx #5
l:  lda loader_cfg_8k,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start

load_splash:
    lda model
    lsr
    beq +n
    jsr $2000
n:

    ldx #5
l:  lda loader_cfg_splash,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start


patch_8k_size = @(length (fetch-file (+ "obj/8k." (downcase (symbol-name *tv*)) ".prg")))
splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_8k:
    $00 $20
    <patch_8k_size @(++ >patch_8k_size)
    <load_splash >load_splash

loader_cfg_splash:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10
