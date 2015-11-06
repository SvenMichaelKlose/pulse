loaded_patch3k:
    org $0400

patch3k:
    jsr preshift_sprites
    lda #<draw_preshifted_sprite
    sta @(+ draw_sprite_caller_1 1)
    sta @(+ draw_sprite_caller_2 1)
    lda #>draw_preshifted_sprite
    sta @(+ draw_sprite_caller_1 2)
    sta @(+ draw_sprite_caller_2 2)

    ; Remove the patch caller.
    lda #$4c    ; JMP
    sta patch_caller
    lda #<post_patch
    sta @(+ 1 patch_caller)
    lda #>post_patch
    sta @(+ 2 patch_caller)
    jmp post_patch
