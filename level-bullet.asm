step_y = 16
inc_x  = 8
inc_y  = 4

add_bullet:
    inc sound_foreground
add_bullet_no_sound:
    ; Get distances to player.

    lda @(+ sprites_x 15)
    cmp sprites_x,x
    bcc +n
    sbc sprites_x,x
    jmp +l
n:  lda sprites_x,x
    sec
    sbc @(+ sprites_x 15)
l:  sta distance_x

    lda @(+ sprites_y 15)
    cmp sprites_y,x
    bcc +n
    sbc sprites_y,x
    jmp +l
n:  lda sprites_y,x
    sec
    sbc @(+ sprites_y 15)
l:  sta distance_y

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
l1: asl                     ; Scale fraction up to byte.
    beq +d1
    bcs +d1
    asl distance_y
    beq +d1
    bcc -l1

d1: and #%11110000          ; Save 4 bits fraction.
    sta @(+ bullet_init 7)
    lda sprites_x,x
    sta bullet_init
    lda sprites_y,x
    sta @(+ bullet_init 1)
    lda tmp
    sta @(+ bullet_init 2)
    ldy #@(-  bullet_init sprite_inits)
    jmp add_sprite
