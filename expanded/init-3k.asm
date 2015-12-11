    $02 $10
    org $1002

    ldx #0
    ldy #$07
l:  lda loaded_patch3k,x
m:  sta $400,x
    dex
    bne -l
    inc @(+ 2 -l)
    inc @(+ 2 -m)
    dey
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

    ; Only +3K. Set patch vector called by game.
    lda #$00
    sta model_patch
    lda #$04
    sta @(++ model_patch)

load_8k:
    ldx #5
l:  lda loader_cfg_8k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight
    jmp tape_loader_start

init_8k:
    ; Set patch vector called by game.
    lda model
    lsr
    beq +n
    jsr $2002
n:

    ; Load splash screen.
    ldx #5
l:  lda loader_cfg_splash,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start


patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))
splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_8k:
    $00 $20
    <patch_8k_size @(++ >patch_8k_size)
    <init_8k >init_8k

loader_cfg_splash:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10

loaded_patch3k:
    @(fetch-file (+ "obj/patch-3k." (downcase (symbol-name *tv*)) ".bin"))
