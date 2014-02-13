free_bricks: .byte 0

init_foreground:
    lda #0
    sta scrolled_bits
    sta scrolled_chars
    sta free_bricks
    sta leftmost_brick
    sta level_delay_bottom
    sta level_pos
    lda #22
    sta level_old_y_bottom
    rts

fetch_foreground_char:
    lda next_foreground_char
    inc next_foreground_char
    jmp fetch_char

draw_trailchar:
.(
    sta s
    jsr fetch_foreground_char
    lda s
    jsr blit_left_whole_char
    lda s
    jsr blit_right_whole_char
    lda d+1
    eor #framemask
    sta scr+1
    lda d
    sta scr
    ldy #7
l1: lda (d),y
    sta (scr),y
    dey
    bpl l1
    rts
.)

no_more_bricks:
#ifdef TIMING
    lda #8+blue
    sta $900f
#endif
    rts

draw_foreground:
#ifdef TIMING
    lda #8+white
    sta $900f
#endif
.(
    lda scrolled_bits
    and #%111
    bne o1
    jsr new_brick
o1:

    lda #0
    ldx #bricks_col-bricks_c-1
i1: sta bricks_c,x
    dex
    bpl i1

    lda #>background
    sta s+1

    lda #foreground
    ora spriteframe
    sta next_foreground_char

    lda scrolled_bits
    and #%111
    bne n1
    inc scrolled_chars
n1: dec scrolled_bits

    lda scrolled_bits
    and #%110
    and #7
    sta blitter_shift_left
    lda #8
    sec
    sbc blitter_shift_left
    and #7
    sta blitter_shift_right

    lda #<background
    jsr draw_trailchar
    lda #<bg_t
    jsr draw_trailchar

    lda leftmost_brick
    sta counter

loop:
    ldx counter
    cpx free_bricks
    beq no_more_bricks
    lda scrbricks_n,x
    sta repetition
    lda scrbricks_y,x
    sta scry
    lda scrbricks_x,x
    sec
    sbc scrolled_chars
    sta tmp3
    sta scrx
    lda scrbricks_i,x
    sta tmp2
    tax
    lda bricks_c,x
    beq draw_chars
restart_plotting_chars:
#ifdef TIMING
    lda #8+red
    sta $900f
#endif
    lda scrx
repeat_plotting_chars:
    cmp #$ff
    beq draw_right      ; Draw only right char...
    cmp #$fe
    beq remove_brick
    cmp #22
    bcs next_brick      ; Off-screen...
    jsr scrcoladdr
    lda bricks_col,x    ; Set left char and color.
    sta (col),y
    lda bricks_c,x
    sta (scr),y
draw_right:
    inc scrx
    lda scrx
    cmp #22             ; Off-screen...
    bcs repeat
    jsr scraddr
    lda blitter_shift_left
    beq plot_trail      ; No shift, plot trail.
    lda bricks_c,x      ; Plot regular right char.
    clc
    adc #1
plot:
    sta (scr),y
repeat:
    dec repetition
    lda repetition
    bmi next_brick
    dec scry
    lda tmp3
    sta scrx
    jmp repeat_plotting_chars
remove_brick:
    jmp remove_brick2
next_brick:
    inc counter
    lda counter
    and #numbricks-1
    sta counter
    jmp loop
plot_trail:
    lda bricks_r,x
    beq plot
    cmp #<background
    bne try_foreground
    lda spriteframe     ; Plot foreground char.
    ora #foreground
    jmp plot
try_foreground:
    cmp #<bg_t
    bne next_brick
    lda spriteframe
    ora #foreground+1
    jmp plot

draw_chars:
#ifdef TIMING
    lda #8+yellow
    sta $900f
#endif
    jsr fetch_foreground_char
    sta bricks_c,x
    lda blitter_shift_left
    beq s1
    lda bricks_l,x
    beq s1
    jsr blit_right_whole_char
s1: lda bricks_m,x
    jsr blit_left_whole_char
    jsr fetch_foreground_char
    lda blitter_shift_left
    beq r1
    lda bricks_m,x
    jsr blit_right_whole_char
    lda bricks_r,x
    beq r1
    jsr blit_left_whole_char
r1: ldx tmp2
    jmp restart_plotting_chars
remove_brick2:
    inc leftmost_brick
    lda leftmost_brick
    and #numbricks-1
    sta leftmost_brick
    jmp next_brick
.)

level_pos:  .byte 0
level_delay_bottom: .byte 0
level_old_y_bottom: .byte 0
level_data:
    .byte 4, 15
    .byte 4, 14
    .byte 4, 13
    .byte 4, 12
    .byte 4, 5
    .byte 4, 10
    .byte 4, 9
    .byte 4, 15
    .byte 4, 10
    .byte 4, 5
    .byte 4, 10
    .byte 4, 15
    .byte 4, 10
    .byte 4, 5
    .byte 4, 15
    .byte 4, 5
    .byte 4, 15
    .byte 4, 5
    .byte 4, 10
    .byte $ff

add_brick:
.(
    pha
    lda free_bricks
    and #numbricks-1
    tax
    clc
    adc #1
    and #numbricks-1
    sta free_bricks
    lda #23
    clc
    adc scrolled_chars
    sta scrbricks_x,x
    lda level_old_y_bottom
    sta scrbricks_y,x
    lda #0
    sta scrbricks_n,x
    pla
    sta scrbricks_i,x
    rts
.)
    
new_brick:
.(
    dec level_delay_bottom
    bpl done
    ldy level_pos
n2: lda level_data,y
    cmp #$ff
    bne n1
    ldy #0
    jmp n2
n1: sta level_delay_bottom
    iny
    lda level_old_y_bottom
    cmp level_data,y
    beq exit
    bcs up

down:
    lda #1
    jsr add_brick
    inc level_old_y_bottom
    lda #3
    jsr add_brick
    lda level_data,y
    sec
    sbc level_old_y_bottom
    sta scrbricks_n,x
    lda level_old_y_bottom
    clc
    adc scrbricks_n,x
    dec scrbricks_n,x
    sta level_old_y_bottom
    sta scrbricks_y,x
    dec scrbricks_y,x
    lda #5
    jsr add_brick
    jmp exit
done:
    rts

up: lda #4
    jsr add_brick
    lda #2
    jsr add_brick
    lda level_old_y_bottom
    sta scrbricks_y,x
    dec scrbricks_y,x
    lda level_old_y_bottom
    sec
    sbc level_data,y
    sta scrbricks_n,x
    lda level_old_y_bottom
    sec
    sbc scrbricks_n,x
    dec scrbricks_n,x
    sta level_old_y_bottom
    lda #0
    jsr add_brick

exit:
    iny
    sty level_pos
    rts
.)
