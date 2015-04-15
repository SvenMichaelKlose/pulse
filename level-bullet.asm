step_y = 16
inc_x  = 8
inc_y  = 4

add_bullet:
    inc sound_foreground
add_bullet_no_sound:
    lda #@(/ deadly step_y)
    sta tmp
    lda @(+ sprites_x 15)    ; Increment or decrement X?
    cmp sprites_x,x
    rol tmp                  ; (inc_x)
    lda @(+ sprites_y 15)    ; Increment or decrement Y?
    cmp sprites_y,x
    rol tmp                  ; (inc_y)
    rol tmp
    rol tmp

    lda @(+ sprites_x 15)    ; Get X distance to player.
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

    lda tmp                  ; Swap axis.
    tay
    and #inc_x
    asl
    sta tmp
    tya
    and #inc_y
    lsr
    ora tmp
    ora #@(+ deadly step_y)
    sta tmp
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
    lda tmp
    sta @(+ bullet_init 2)
    ldy #@(-  bullet_init sprite_inits)
    jmp add_sprite
