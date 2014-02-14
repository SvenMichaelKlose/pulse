add_stars:
.(
    lda framecounter
    and #%111
    bne l1
    lda random
    and #%01111000
    sta star_init+1
    ldy #star_init-sprite_inits
    jmp add_sprite
l1: rts
.)
