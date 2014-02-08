scrbricks_i:.byte 0, 0, 0, 0, $ff
scrbricks_x:.byte 21, 21, 21, 21
scrbricks_y:.byte 18, 19, 20, 21

bricks_c:   .byte 0, 0, 0, 0
bricks_col: .byte yellow+8, 0, 0, 0
bricks_l:   .byte <background, 0, 0, 0
bricks_m:   .byte <background, 0, 0, 0
bricks_r:   .byte <background, 0, 0, 0

init_background:
    ldy #0
    dey
    sty leftmost_brick
    sty scroll
    sty scrollchars
    rts

ret1:
    rts
draw_background:
.(
    lda #0
    sta sprshifty
    ldx #3
i1: sta bricks_c,x
    dex
    bpl i1

    lda #>background
    sta spr+1
    inc scroll
    lda scroll
    and #%111
    bne n1
    inc scrollchars
n1:

    jsr alloc_char
    lda scroll
    and #%110
    sta sprshiftx
    sta tmp2
    lda #<background
    sta spr
    jsr blit_right_whole_char

    lda #8
    sec
    sbc sprshiftx
    and #7
    sta sprshiftx
    sta tmp3
    jsr blit_left_whole_char

    ldx leftmost_brick
    stx counter
next_brick:
    inc counter
retry_brick:
    ldx counter         ; Screen brick.
    lda scrbricks_i,x
    bmi ret1            ; No more bricks to draw.

    lda scrbricks_x,x
    sec                 ; Move brick left in matters of progressed scrolling.
    sbc scrollchars
    cmp #$ff            ; Brick outside screen?
    bne plot_chars
    lda #21
    clc
    adc scrollchars
    sta scrbricks_x,x
    jmp retry_brick

plot_chars:
    cmp #22
    bcs next_brick
    sta scrx            ; Get screen address.
    lda scrbricks_y,x
    sta scry
    jsr scrcoladdr
    lda scrbricks_i,x
    tax
    lda bricks_col,x    ; Set color.
    ldy #0
    sta (col),y

restart_plotting_chars:
    ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_c,x
    beq draw_chars
    ldy #0
    sta (scr),y
    inc scrx
    lda scrx
    cmp #22
    beq next_brick
    jsr scraddr
    lda tmp2
    bne n2
    lda bricks_r,x
    bne n4
    lda #0
    jmp n3
n4: cmp #<background
    bne n2
    lda sprbank
    bne n3
    ora #1
    jmp n3
n2: lda bricks_c,x
    clc
    adc #1
n3: ldy #0
    sta (scr),y
    jmp next_brick

draw_chars:
    ldx counter
    lda scrbricks_i,x
    tax
    jsr alloc_char
    sta bricks_c,x

    lda tmp2
    sta sprshiftx
    lda bricks_l,x
    sta spr
    jsr blit_right_whole_char

    lda tmp3
    sta sprshiftx
    ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_m,x
    sta spr
    jsr blit_left_whole_char

    lda tmp2
    sta sprshiftx
    jsr alloc_char

    ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_r,x
    sta spr
    jsr blit_right_whole_char

    lda tmp3
    sta sprshiftx
    ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_m,x
    sta spr
    jsr blit_left_whole_char

    ldx counter
    lda scrbricks_i,x
    tax
    jmp restart_plotting_chars
.)
