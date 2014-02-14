add_stars:
.(
    lda addedsprites
    cmp #13
    bcs l1
    lda framecounter
    and #%111
    bne l1
    lda random
    and #%01111000
    sta bullet_init+1
    lda random
    and #3
    ora #8
    sta bullet_init+3
    ldy #bullet_init-sprite_inits
    jmp add_sprite
l1: rts
.)
