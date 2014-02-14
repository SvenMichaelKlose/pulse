readd_star:
.(
    txa
    pha
    tya
    pha
    lda random
    and #%11111000
    sta star_init
    jsr update_random
    jsr add_star
    pla
    tay
    pla
    tax
    rts
.)

add_stars:
    lda framecounter
    and #%111
    bne return4
add_star:
    lda random
    and #%11111000
    sta star_init+1
    ldy #star_init-sprite_inits
    jmp add_sprite
return4:
    rts
