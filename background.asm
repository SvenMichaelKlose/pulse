scrbricks:  .byte $00, $ff
bricks_x:   .byte 21
bricks_y:   .byte 18
bricks_c:   .byte $00

bricks_col: .byte yellow+8
bricks_l:   .byte <background
bricks_m:   .byte <background
bricks_r:   .byte <background

init_background:
    lda #0
    sta leftmost_brick
    sta scroll
    sta scrollchars
add_brick:
    rts

ret1:
    inc sprchar
    rts
draw_background:
.(
    lda #0
    sta sprshifty
    lda #>background
    sta spr+1
    inc scroll
    lda scroll
    and #%111
    bne s1
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
;    jsr add_brick       ; Add new on right.
;    lda bricks_x,y
;    clc
;    adc scrollchars
;    sta bricks_x,y
    jmp s1
n1: sta scrx            ; Get screen address.
    lda bricks_y,x
    sta scry
    jsr scrcoladdr
d1: lda bricks_col,x    ; Set color.
    ldy #0
    sta (col),y
    lda bricks_c,x      ; Plot first char.
    beq n2              ; Need to make the chars first...
    sta (scr),y
    inc scrx            ; Plot second char.
    ldy scrx
    cpy #22             ; Ignore off-screen char.
    beq l1
    jsr scrcoladdr
    ldy #0
    sta (scr),y
    jmp l1
n2: lda scroll          ; Draw brick to charset.
    and #%111
    sta sprshiftx
    sta tmp
    lda sprchar
    sta bricks_c,x      ; Save starting char of brick.
    jsr alloc_char
    lda bricks_l,x
    sta spr
    jsr blit_right_whole_char
    lda bricks_m,x
    sta spr
    sec                 ; Invert shift for right sides.
    sbc sprshiftx
    sta sprshiftx
    jsr blit_left_whole_char
    inc sprchar
    lda d
    clc
    adc #8
    sta d
    lda bricks_r,x
    sta spr
    jsr blit_left_whole_char
    lda tmp
    sta sprshiftx
    lda bricks_m,x
    sta spr
    jsr blit_right_whole_char
    jmp d1
.)
