add_sniper:
    ldy level_old_y
    dey
    tya
    asl
    asl
    asl
    sta sniper_init+1
    lda #22*8
    sta sniper_init
    ldy #sniper_init-sprite_inits
    jmp add_sprite
