step_y = 16
inc_x  = 8
inc_y  = 4

add_bullet:
    inc sound_foreground
    jsr add_bullet_no_sound
    jmp add_sprite

add_bullet_no_sound:
    ; Get distance to player.
    lda @(+ sprites_x 15)
    sec
    sbc sprites_x,x
    jsr abs
    sta distance_x
    lda @(+ sprites_y 15)
    sec
    sbc sprites_y,x
    jsr abs
    sta distance_y

    lda #@(/ deadly decorative)
    sta tmp

    lda distance_y
    cmp distance_x
    bcc +n

    ; Step on longer Y.
    ldy distance_x
    lda distance_y
    sta distance_x
    sty distance_y

n:  rol tmp                 ; (step_y)

    lda @(+ sprites_x 15)   ; Increment or decrement X?
    cmp sprites_x,x
    rol tmp                 ; (inc_x)
    lda @(+ sprites_y 15)   ; Increment or decrement Y?
    cmp sprites_y,x
    lda tmp
    rol                     ; (inc_y)
    asl                     ; Shift sprite flags into place.
    asl
    sta @(+ bullet_init 2)

    lda distance_x
l:  asl                     ; Scale fraction up to byte.
    beq +l
    bcs +l
    asl distance_y
    beq +l
    bcc -l

l:  ror
    and #%11110000          ; Save 4 bits fraction.
    sta @(+ bullet_init 7)
    lda sprites_x,x
    sta bullet_init
    lda sprites_y,x
    sta @(+ bullet_init 1)
    ldy #@(- bullet_init sprite_inits)
    rts
