add_star:
.(
    tya
    pha
    lda random
    sta star_init
    jsr update_random
    lda random
    and #%11111000
    sta star_init+1
    jsr update_random
    lda random
    sta star_init+7
    ldy #star_init-sprite_inits
    jsr add_sprite
    jsr update_random
    pla
    tay
    rts
.)
