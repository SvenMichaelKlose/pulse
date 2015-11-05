;    $02 $10
    org $1000

    ldx #5
l:  lda loader_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jmp tape_loader_start

    ; Set patch vector called by game.
;    lda #<patch3k
;    sta model_patch
;    lda #>patch3k
;    sta @(++ model_patch)
    rts

splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))                                                          
loader_cfg:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10

patch3k:
    jsr preshift_sprites
    lda #<draw_preshifted_sprite
    sta @(+ draw_sprite_caller 2)
    lda #>draw_preshifted_sprite
    sta @(+ draw_sprite_caller 3)

    lda #$ea    ; NOP
    sta game_over
    sta @(+ 1 game_over)
    sta @(+ 2 game_over)
    jmp post_patch
