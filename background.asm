scrbricks_i:.byte 0, 1
            .byte 0, 1
            .byte 0, 1
            .byte 0, 1
            .byte 0, 1
            .byte 0, 1
            .byte 0, 1
            .byte 0, 1
            .byte $ff
scrbricks_x:.byte 22, 28
            .byte 23, 29
            .byte 24, 30
            .byte 25, 31
            .byte 26, 32
            .byte 27, 33
            .byte 28, 34
            .byte 29, 35
scrbricks_y:.byte 14, 14
            .byte 15, 15
            .byte 16, 16
            .byte 17, 17
            .byte 18, 18
            .byte 19, 19
            .byte 20, 20
            .byte 21, 21

bricks_c:   .byte 0, 0, 0, 0
bricks_col: .byte yellow+8, yellow+8, 0, 0
bricks_l:   .byte 0, <background, 0, 0
bricks_m:   .byte <background, <background, 0, 0
bricks_r:   .byte <background, 0, 0, 0

init_background:
    ldy #0
    sty scroll
    sty scrollchars
    dey
    sty leftmost_brick
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
    lda scroll
    and #%111
    bne n1
    inc scrollchars
n1: dec scroll

    jsr alloc_char
    lda scroll
    and #%110
    sta sprshiftx
    sta tmp2
    lda #<background
    sta spr
    jsr blit_left_whole_char

    lda #8
    sec
    sbc sprshiftx
    and #7
    sta sprshiftx
    sta tmp3
    jsr blit_right_whole_char

    ldx leftmost_brick
    stx counter
next_brick:
    inc counter
retry_brick:
    ldx counter         ; Screen brick.
    lda scrbricks_i,x
    bmi ret1            ; No more bricks to draw.

    lda scrbricks_y,x
    sta scry
    lda scrbricks_x,x
    sec                 ; Move brick left in matters of progressed scrolling.
    sbc scrollchars
    sta scrx
    cmp #$ff
    beq clear_right
    cmp #$fe
    beq new_brick
    cmp #22
    bcs next_brick
    jmp plot_chars
new_brick:
    lda #21
    clc
    adc scrollchars
    sta scrbricks_x,x
    jmp retry_brick

plot_chars:
    lda scrx
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
clear_right:
    ldx counter
    lda scrbricks_i,x
    tax
    inc scrx
    lda scrx
    cmp #22
    bcs next_brick
    jsr scraddr
    lda tmp2
    bne n2
    lda bricks_r,x
    beq n3              ; Plot background char.
n4: cmp #<background
    bne n2
    lda sprbank         ; Plot foreground char.
    bne n3
    ora #1
    jmp n3
n2: lda bricks_c,x      ; Plot right char.
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

    lda bricks_l,x
    beq s1
    sta spr
    lda tmp3
    sta sprshiftx
    jsr blit_right_whole_char

s1: ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_m,x
    beq s2
    sta spr
    lda tmp2
    sta sprshiftx
    jsr blit_left_whole_char

s2: lda tmp3
    sta sprshiftx
    jsr alloc_char

    ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_m,x
    beq s3
    sta spr
    jsr blit_right_whole_char

s3: ldx counter
    lda scrbricks_i,x
    tax
    lda bricks_r,x
    beq s4
    sta spr
    lda tmp2
    sta sprshiftx
    jsr blit_left_whole_char

s4: ldx counter
    lda scrbricks_i,x
    tax
    jmp restart_plotting_chars
.)
