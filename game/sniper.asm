    ; Add a sniper on occasion.
    jsr random
mod_sniper_probability:
    and #sniper_probability
    bne +n
    ldy level_old_y
    dey
    tya
    asl
    asl
    asl
    sta @(++ sniper_init)
    lda #@(* screen_width 8)
    sta sniper_init
    ldy #@(- sniper_init sprite_inits)
    jsr add_sprite
n:
