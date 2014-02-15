step_y = 16
dec_x  = 8
dec_y  = 4

abs:
.(
    bpl n3
    eor #$ff
    clc
    adc #0
n3: rts
.)

add_bullet:
.(
    lda #64
    sta bullet_init+2   ; Increment or decrement X?
    lda sprites_x+15
    cmp sprites_x,x
    bcs n1
    lda bullet_init+2
    ora #dec_x
    sta bullet_init+2
n1: lda sprites_y+15    ; Increment or decrement Y?
    cmp sprites_y,x
    bcs n2
    lda bullet_init+2
    ora #dec_y
    sta bullet_init+2
n2: lda sprites_x+15    ; Get X distance.
    sec
    sbc sprites_x,x
    jsr abs
    sta tmp
    lda sprites_y+15    ; Get Y distance.
    sec
    sbc sprites_y,x
    jsr abs
    sta tmp2
    cmp tmp             ; Get incremented axis.
    bcc n5
    lda bullet_init+2
    and #dec_x
    lsl
    tay
    lda bullet_init+2
    and #dec_y
    lsr
    sta bullet_init+2
    tya
    ora bullet_init+2
    ora #64+step_y
    sta bullet_init+2
    ldy tmp
    lda tmp2
    sta tmp
    sty tmp2
n5: lda tmp
    beq d1
    lda tmp2
    beq d1
l1: lda tmp             ; Scale fraction up to byte.
    asl                 ; (partial multiplication)
    sta tmp
    bcs d1
    lda tmp2
    asl
    bcs d1
    sta tmp2
    jmp l1
d1: lda tmp2
    and #%11110000      ; Save 4 bits fraction.
    sta bullet_init+7
    lda sprites_x,x
    sta bullet_init
    lda sprites_y,x
    sta bullet_init+1
    ldy #bullet_init-sprite_inits
    jmp add_sprite
.)
