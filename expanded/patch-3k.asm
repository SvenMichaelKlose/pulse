loaded_patch3k:
    org $0400

patch3k:
    jsr preshift_sprites
    lda #<draw_preshifted_sprite
    sta @(+ draw_sprite_caller 1)
    lda #>draw_preshifted_sprite
    sta @(+ draw_sprite_caller 2)

    lda #$ea    ; NOP
    sta game_over
    sta @(+ 1 game_over)
    sta @(+ 2 game_over)
    jmp post_patch
