ret1:
add_brick:
    rts
draw_background:
.(
    inc scroll
    and #%111
    beq s1
    inc scrollchars
s1: ldx leftmost_brick
    stx tmp
l1: ldx tmp             ; Screen brick.
    inc tmp
    lda scrbricks,x
    bmi ret1            ; No more bricks to draw.
    tax
    lda bricks_x,x
    sec                 ; Move brick left in matters of progressed scrolling.
    sbc scrollchars
    cmp #$ff            ; Brick outside screen?
    bne n1
    inc leftmost_brick  ; Remove left brick.
    jsr add_brick       ; Add new on right.
    lda bricks_x,y
    clc
    adc scrollchars
    sta bricks_x,y
    jmp l1
n1: sta scrx            ; Get screen address.
    lda bricks_y,x
    sta scry
    jsr scrcoladdr
    lda bricks_c,x      ; Set color.
    lsr
    lsr
    lsr
    lsr
    ldy #0
    sta (col),y
    lda bricks_c,x      ; Plot first char.
    and #%1111
    beq n2
    sta (scr),y
    inc scrx            ; Plot second char.
    ldy scrx
    cpy #22
    beq l1
    jsr scrcoladdr
    ldy #0
    sta (scr),y
    jmp l1
n2: lda scroll          ; Draw brick to charset.
    and #%111
    sta sprshiftx
    lda bricks_c,x
    and #%11110000
    ora sprchar
    sta bricks_c,x
    lda sprchar
    asl
    asl
    asl
    ora sprbank
    sta d
    lda sprchar
    lsr
    lsr
    lsr
    lsr
    lsr
    sta d+1
    lda bricks_l,x
    jsr blit_right_whole_char
    lda bricks_m,x
    jsr blit_right_whole_char
    sec                 ; Invert shift for right sides.
    sbc sprshiftx
    sta sprshiftx
    inc sprchar
    lda d
    clc
    adc #8
    sta d
    lda bricks_m,x
    jsr blit_left_whole_char
    lda bricks_r,x
    jsr blit_left_whole_char
    inc sprchar
    pla
    tax
    dex
    jmp l1
.)
