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
            .byte 28, 47
scrbricks_y:.byte 15, 15
            .byte 16, 16
            .byte 17, 17
            .byte 18, 18
            .byte 19, 19
            .byte 20, 20
            .byte 21, 21
            .byte 22, 22

bricks_c:   .byte 0, 0, 0, 0, 0, 0
bricks_col: .byte yellow+8, yellow+8, yellow+8,    yellow+8,    yellow+8,    yellow+8
bricks_l:   .byte 0,        <bg_t,    0,           <background, <background, <bg_t
bricks_m:   .byte <bg_tl,   <bg_tr,   <bg_l,       <bg_r,       <bg_dl,      <bg_dr
bricks_r:   .byte <bg_t,    0,        <background, 0,           <bg_t,       <background

init_background:
    ldy #0
    sty scroll
    sty scrollchars
    dey
    sty leftmost_brick
    rts

draw_tailchar:
.(
    sta s
    jsr alloc_char
    lda s
    jsr blit_left_whole_char
    lda s
    jsr blit_right_whole_char
    lda d+1
    eor #sprbufmask
    sta scr+1
    lda d
    sta scr
    ldy #7
l1: lda (d),y
    sta (scr),y
    dey
    bpl l1
.)

ret1:
    rts

draw_background:
.(
    lda #0
    ldx #bricks_col-bricks_c-1
i1: sta bricks_c,x
    dex
    bpl i1

    lda #>background
    sta s+1

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
    jsr draw_tailchar
    lda #<bg_t
    jsr draw_tailchar

    lda leftmost_brick
    sta counter

next_brick:
    inc counter
retry_brick:
    ldx counter         ; Screen brick.
    lda scrbricks_i,x
    bmi ret1            ; No more bricks to draw.
    sta tmp2
    lda scrbricks_y,x   ; Get screen position.
    sta scry
    lda scrbricks_x,x
    sec
    sbc scrollchars
    sta scrx
    ldx tmp2
    lda bricks_c,x
    beq draw_chars
restart_plotting_chars:
    ldx tmp2
    lda scrx
    cmp #$ff
    beq draw_right      ; Draw only right char...
    cmp #$fe
    beq new_brick       ; Replace brick...
    cmp #22
    bcs next_brick      ; Off-screen...
    jsr scrcoladdr
    lda bricks_col,x    ; Set color.
    ldy #0
    sta (col),y
    lda bricks_c,x
    ldy #0
    sta (scr),y
draw_right:
    inc scrx
    lda scrx
    cmp #22
    bcs next_brick      ; Off-screen.
    jsr scraddr
    lda sprshiftxl
    beq plot_trail      ; No shift, plot trail.
    lda bricks_c,x      ; Plot regular right char.
    clc
    adc #1
plot:
    ldy #0
    sta (scr),y
    jmp next_brick
plot_trail:
    lda bricks_r,x
    beq plot            ; Plot background char.
    cmp #<background
    bne try_foreground
    lda sprbank         ; Plot foreground char.
    ora #first_char
    jmp plot
try_foreground:
    cmp #<bg_t
    bne next_brick
    lda sprbank
    ora #2
    jmp plot

new_brick:
    lda #23
    clc
    adc scrollchars
    ldx counter
    sta scrbricks_x,x
    jmp next_brick

draw_chars:
    jsr alloc_char
    ldx tmp2
    sta bricks_c,x
    lda sprshiftxl
    beq s1
    lda bricks_l,x
    beq s1
    jsr blit_right_whole_char
    ldx tmp2
s1: lda bricks_m,x
    jsr blit_left_whole_char
    jsr alloc_char
    ldx tmp2
    lda sprshiftxl
    beq r1
    lda bricks_m,x
    jsr blit_right_whole_char
    ldx tmp2
    lda bricks_r,x
    beq r1
    jsr blit_left_whole_char
r1: ldx tmp2
    jmp restart_plotting_chars
.)
