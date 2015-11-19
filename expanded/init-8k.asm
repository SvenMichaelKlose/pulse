;    $02 $10
    org $1000

    ldx #5
l:  lda loader_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    ldx #0
l:  lda loaded_patch8k,x
    sta patch8k,x
    lda @(+ #x100 loaded_patch8k),x
    sta @(+ #x100 patch8k),x
    dex
    bne -l

    lda #<post_patch
    sta model_patch
    lda #>post_patch
    sta @(++ model_patch)

    ; Check if there's minimum +8K RAM.
    lda model
    lsr
    bne +i

    ; Set patch vector called by game.
    lda #<patch8k
    sta model_patch
    lda #>patch8k
    sta @(++ model_patch)

i:  jmp tape_loader_start

splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))                                                          
loader_cfg:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10
