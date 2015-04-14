step_y = 16
dec_x  = 8
dec_y  = 4

add_bullet:
    inc sound_foreground
    lda #64
    sta @(+ bullet_init 2)
    lda @(+ sprites_x 15)    ; Increment or decrement X?
    cmp sprites_x,x
    bcs +n1
    lda @(+ bullet_init 2)
    ora #dec_x
    sta @(+ bullet_init 2)
n1: lda @(+ sprites_y 15)    ; Increment or decrement Y?
    cmp sprites_y,x
    bcs +n2
    lda @(+ bullet_init 2)
    ora #dec_y
    sta @(+ bullet_init 2)
n2: lda @(+ sprites_x 15)    ; Get X distance to player.
    sec
    sbc sprites_x,x
    jsr abs
    sta distance_x
    lda @(+ sprites_y 15)    ; Get Y distance to player.
    sec
    sbc sprites_y,x
    jsr abs
    sta distance_y
    cmp distance_x           ; Get incremented axis.
    bcc +n5
    lda @(+ bullet_init 2)   ; Swap axis.
    and #dec_x
    asl
    tay
    lda @(+ bullet_init 2)
    and #dec_y
    lsr
    sta @(+ bullet_init 2)
    tya
    ora @(+ bullet_init 2)
    ora #64+step_y
    sta @(+ bullet_init 2)
    ldy distance_x
    lda distance_y
    sta distance_x
    sty distance_y
n5: lda distance_x
    beq +d1
    lda distance_y
    beq +d1
l1: asl distance_x             ; Scale fraction up to byte.
    bcs +d1
    asl distance_y
    bcc -l1
d1: lda distance_y
    and #%11110000      ; Save 4 bits fraction.
    sta @(+ bullet_init 7)
    lda sprites_x,x
    sta bullet_init
    lda sprites_y,x
    sta @(+ bullet_init 1)
    ldy #@(-  bullet_init sprite_inits)
    jmp add_sprite
