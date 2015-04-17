step_y = 16
inc_x  = 8
inc_y  = 4

absolute_difference:
    sta tmp2
    sty tmp
    cmp tmp
    bcc +n
    sbc tmp
    jmp +l
n:  lda tmp
    sec
    sbc tmp2
l:  rts

add_bullet:
    inc sound_foreground
add_bullet_no_sound:
    ; Get distance to player.
    lda @(+ sprites_x 15)
    ldy sprites_x,x
    jsr absolute_difference
    sta distance_x
    lda @(+ sprites_y 15)
    ldy sprites_y,x
    jsr absolute_difference
    sta distance_y

    lda #@(/ deadly decorative)
    sta tmp

    ; Swap axis.
    lda distance_y
    cmp distance_x
    bcs +n
    ldy distance_x
    lda distance_y
    sta distance_x
    sty distance_y
n:  rol tmp                 ; (step_y)

    lda @(+ sprites_x 15)    ; Increment or decrement X?
    cmp sprites_x,x
    rol tmp                  ; (inc_x)
    lda @(+ sprites_y 15)    ; Increment or decrement Y?
    cmp sprites_y,x
    rol tmp                  ; (inc_y)
    rol tmp
    rol tmp

    lda distance_x
l:  asl                     ; Scale fraction up to byte.
    beq +l
    bcs +l
    asl distance_y
    beq +l
    bcc -l

l:  and #%11110000          ; Save 4 bits fraction.
    sta @(+ bullet_init 7)
    lda sprites_x,x
    sta bullet_init
    lda sprites_y,x
    sta @(+ bullet_init 1)
    lda tmp
    sta @(+ bullet_init 2)
    ldy #@(-  bullet_init sprite_inits)
    jmp add_sprite
