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

init_8k:
    ; Set patch vector called by game.
    lda model
    lsr
    beq +n
    jsr $2002
n:

    ; Load +16K block.
    ldx #5
l:  lda loader_cfg_16k,x
    sta tape_ptr,x
    dex
    bpl -l
;    jmp tape_loader_start

init_16k:
    ; Load +24K block.
    ldx #5
l:  lda loader_cfg_24k,x
    sta tape_ptr,x
    dex
    bpl -l
;    jmp tape_loader_start

init_24k:
    ; Load +32K block.
    ldx #5
l:  lda loader_cfg_32k,x
    sta tape_ptr,x
    dex
    bpl -l
;    jmp tape_loader_start

init_32k:
    ; Load splash screen.
    ldx #5
l:  lda loader_cfg_splash,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start


patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))
patch_16k_size = $1000
patch_24k_size = $1000
patch_32k_size = $1000
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

loaded_patch3k:
    @(fetch-file (+ "obj/patch-3k." (downcase (symbol-name *tv*)) ".bin"))
