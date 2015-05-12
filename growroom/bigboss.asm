init_bigboss:
    ldy #bigboss_size   ; Switch to updating trajectories.
    sty is_forming
l1: lda sprites_fl,y     ; Turn scouts into snake parts.
    cmp #<scout_fun
    bne l2
    lda #<bigboss_fun
    sta sprites_fl,y
    lda #>bigboss_fun
    sta sprites_fh,y
l2: dey
    bpl l1
    rts

bigboss_fun:
    ; Wait before fire.
    lda bb_fire
    bmi start_forming
    beq fire
fired:
    dec bb_before_fire
    rts

    ; Fire.
fire:
    jmp fired

start_forming:
    lda is_forming
    beq form
    dec is_forming
    jsr calculate_trajectory
    jsr replace_sprite

form:
    jsr traject
    jmp traject
