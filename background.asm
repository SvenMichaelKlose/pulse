scrbricks_i:.byte 0, 1
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 4, 5
            .byte $ff
scrbricks_x:.byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 28, 45
scrbricks_y:.byte 15, 15
            .byte 16, 16
            .byte 17, 17
            .byte 18, 18
            .byte 19, 19
            .byte 20, 20
            .byte 21, 21
            .byte 22, 22

bricks_c:   .byte 0, 0, 0, 0
            .byte 0, 0
bricks_col: .byte yellow+8, yellow+8, yellow+8, yellow+8
            .byte yellow+8, yellow+8
bricks_l:   .byte 0, <bg_t, 0, <background
            .byte <background, <bg_t
bricks_m:   .byte <bg_tl, <bg_tr, <bg_l, <bg_r
            .byte <bg_dl, <bg_dr
bricks_r:   .byte <bg_t, 0, <background, 0
            .byte <bg_t, <background

init_background:
    ldy #0
    sty scroll
    sty scrollchars
    dey
    sty leftmost_brick
    rts

draw_middlechar:
.(
    jsr alloc_char
    jsr blit_left_whole_char
    jsr blit_right_whole_char
    lda d+1
    eor #sprbufmask
    sta s+1
    lda d
    sta s
    ldy #7
l1: lda (d),y
    sta (s),y
    dey
    bpl l1
.)

ret1:
    rts
draw_background:
.(
    lda #0
    sta sprshifty
    ldx #bricks_col-bricks_c-1
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

    lda scroll
    and #%110
    and #7
    sta sprshiftxl
    lda #8
    sec
    sbc sprshiftxl
    and #7
    sta sprshiftxr

    lda #<background
    sta spr
    jsr draw_middlechar

    lda #<bg_t
    sta spr
    jsr draw_middlechar

    ldx leftmost_brick
    stx counter
next_brick:
    inc counter
retry_brick:
    ldx counter         ; Screen brick.
    lda scrbricks_i,x
    sta tmp2
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
    ldx tmp2
    lda bricks_col,x    ; Set color.
    ldy #0
    sta (col),y
restart_plotting_chars:
    lda bricks_c,x
    beq draw_chars
    ldy #0
    sta (scr),y
clear_right:
    ldx tmp2
    inc scrx
    lda scrx
    cmp #22
    bcs next_brick
    jsr scraddr
    lda sprshiftxl
    bne n2
    lda bricks_r,x
    beq n3              ; Plot background char.
n4: cmp #<background
    bne n2
    lda sprbank         ; Plot foreground char.
    ora #first_char
    jmp n3
n2: cmp #<bg_t
    bne n5
    lda sprbank
    ora #2
    jmp n3
n5: lda bricks_c,x      ; Plot right char.
    clc
    adc #1
n3: ldy #0
    sta (scr),y
    jmp next_brick

draw_chars:
    jsr alloc_char
    ldx tmp2
    sta bricks_c,x

    lda bricks_l,x
    beq s1
    sta spr
    jsr blit_right_whole_char

s1: ldx tmp2
    lda bricks_m,x
    beq s2
    sta spr
    jsr blit_left_whole_char

s2: jsr alloc_char

    ldx tmp2
    lda bricks_m,x
    beq s3
    sta spr
    jsr blit_right_whole_char

s3: ldx tmp2
    lda bricks_r,x
    beq s4
    sta spr
    jsr blit_left_whole_char

s4: ldx tmp2
    jmp restart_plotting_chars
.)
