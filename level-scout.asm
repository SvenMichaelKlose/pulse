add_scout:
.(
    lda framecounter
    and #%01111111
    bne l1
retry:
    jsr random
    and #%01111000
    clc
    adc #16
    sta scout_formation_y
    lsr
    lsr
    lsr
    sta scry
    lda #21
    sta scrx
    jsr scraddr
    jsr test_on_foreground
    beq retry
    lda #8
    sta adding_scout
    sta formation_left_unhit
    lda #3
    sta adding_scout_delay
l1: lda adding_scout
    beq l2
    dec adding_scout_delay
    bne l2
    lda #3
    sta adding_scout_delay
    dec adding_scout
    lda scout_formation_y
    sta scout_init+1
    ldy #scout_init-sprite_inits
    jmp add_sprite
l2: rts
.)
