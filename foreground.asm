init_foreground:
    ldy #0
    sty scrolled_bits
    sty scrolled_chars
    dey
    sty leftmost_brick
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

next_brick:
    inc counter
retry_brick:
    ldx counter
    lda scrbricks_i,x
    bmi no_more_bricks
    sta tmp2
    lda scrbricks_n,x
    sta repetition
    lda scrbricks_y,x
    sta scry
    lda scrbricks_x,x
    sec
    sbc scrolled_chars
    sta tmp3
    sta scrx
    ldx tmp2
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
    beq new_brick       ; Replace brick...
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

new_brick:
    lda #23
    clc
    adc scrolled_chars
    ldx counter
    sta scrbricks_x,x
    jmp next_brick

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
.)

init_scrbricks:
.(
    ldx #5
l1: txa
    sta scrbricks_i,x
    lda #0
    sta scrbricks_n,x
    dex
    bne l1
    lda #4
    sta scrbricks_n+2
    sta scrbricks_n+3
    lda #$ff
    sta scrbricks_i+6

    lda #22
    sta scrbricks_x
    lda #28
    sta scrbricks_x+1
    lda #22
    sta scrbricks_x+2
    lda #28
    sta scrbricks_x+3
    lda #28
    sta scrbricks_x+4
    lda #47
    sta scrbricks_x+5

    lda #23-7
    sta scrbricks_y
    sta scrbricks_y+1
    lda #21
    sta scrbricks_y+2
    sta scrbricks_y+3
    lda #22
    sta scrbricks_y+4
    sta scrbricks_y+5
    rts
.)
