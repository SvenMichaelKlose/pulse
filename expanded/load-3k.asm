;    $02 $10
    org $1000

    ldx #5
l:  lda loader_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

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

    lda model
    beq +i
    lsr
    bne +i
    bcc +i

    ; Set patch vector called by game.
    lda #<patch3k
    sta model_patch
    lda #>patch3k
    sta @(++ model_patch)

i:  jmp tape_loader_start

splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))                                                          
loader_cfg:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10
