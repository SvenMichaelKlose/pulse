    org $400

    ; Set patch vector called by game.
    lda #<patch3k
    sta $1ffb
    lda #>patch3k
    sta $1ffc
    rts

patch3k:
    jsr preshift_sprites
    lda #<draw_preshifted_sprite
    sta @(+ draw_sprite_caller 2)
    lda #>draw_preshifted_sprite
    sta @(+ draw_sprite_caller 3)
    rts
