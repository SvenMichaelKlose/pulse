preshifted_sprites = @(- #x4000 #x480)

patch8k:
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
    lda #<title_screen
    sta @(+ 1 patch_caller)
    lda #>title_screen
    sta @(+ 2 patch_caller)
    jmp get_ready
