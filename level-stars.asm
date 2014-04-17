add_star:
.(
    tya
    pha
    jsr random
    sta star_init       ; Set X position.
    jsr random
    and #%11111000
    sta star_init+1     ; Set Y position.
    jsr random
    sta star_init+7     ; Set speed.
    ldy #star_init-sprite_inits
    jsr add_sprite
    pla
    tay
    rts
.)
