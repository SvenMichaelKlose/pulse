add_star:
.(
    tya
    pha
    jsr random
    sta star_init
    jsr random
#ifndef M3K
    and #%11111000
#endif
    sta star_init+1
    jsr random
    sta star_init+7
    ldy #star_init-sprite_inits
    jsr add_sprite
    pla
    tay
    rts
.)
