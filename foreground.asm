bricklist_r:    .dsb 8

test_on_foreground:
    ldy #0
    lda (scr),y
    and #foreground
    cmp #foreground
    rts

add_brick:
.(
    pha
    lda free_bricks
    tax
    clc
    adc #1
    and #numbricks-1
    sta free_bricks
    lda #22
    clc
    adc scrolled_chars
    sta scrbricks_x,x
    lda level_old_y
    sta scrbricks_y,x
    lda #0
    sta scrbricks_n,x
    pla
    sta scrbricks_i,x
    rts
.)

fetch_foreground_char:
    lda next_foreground_char
    inc next_foreground_char
    jmp fetch_char

draw_foreground:
.(
    lda scrolled_bits
    dec scrolled_bits
    and #%111
    beq n1
    lda framecounter
    and #1
    bne no_more_bricks
    lda scrolled_chars
    jmp rotate_bricks
no_more_bricks:
    rts

n1: inc scrolled_chars

reset_chars:
    lda #0
    ldx #bricks_col-bricks_c-1
i1: sta bricks_c,x
    dex
    bpl i1
    sta active_bricks
    lda #framemask+foreground+2
    sta next_foreground_char
    lda leftmost_brick
    sta counter

loop:
    lda counter
    and #numbricks-1
    cmp free_bricks
    beq no_more_bricks
    tax
    lda scrbricks_n,x
    sta repetition
    lda scrbricks_y,x
    sta scry
    lda scrbricks_x,x
    sec
    sbc scrolled_chars
    sta scrx
    sta tmp3                ; Save X for repetition.
    lda scrbricks_i,x
    sta tmp2
    tax
    lda bricks_c,x
    beq draw_chars

restart_plotting_chars:
    lda scrx
repeat_plotting_chars:
    cmp #$fd
    beq remove_brick
    bcs draw_right
    cmp #22
    bcs no_more_bricks  ; Off-screen...
    jsr scrcoladdr
    lda bricks_col,x    ; Set left char and color.
    sta (col),y
    lda bricks_c,x
    sta (scr),y
draw_right:
    inc scrx
    lda scrx
    cmp #22             ; Off-screen...
    bcs n2
    jsr scraddr
    lda bricks_c,x      ; Plot regular right char.
    clc
    adc #1
    sta (scr),y
n2: inc scrx
    lda scrx
    cmp #22             ; Off-screen...
    bcs repeat
    jsr scraddr
    lda bricks_r,x
    beq plot
    cmp #<background
    bne try_foreground
    lda spriteframe     ; Plot foreground char.
    ora #foreground
    jmp plot
try_foreground:
    cmp #<bg_t
    bne repeat
    lda spriteframe
    ora #foreground+1
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
    inc leftmost_brick
    lda leftmost_brick
    and #numbricks-1
    sta leftmost_brick
next_brick:
    inc counter
    jmp loop

draw_chars:
    jsr fetch_foreground_char
    sta bricks_c,x
    lda bricks_l,x
    beq n4
    jsr blit_char
    jmp n5
n4: jsr blit_clear_char
n5: jsr fetch_foreground_char
    lda bricks_m,x
    jsr blit_char
    lda bricks_r,x
    ldy active_bricks
    sta bricklist_r,y
    inc active_bricks
    ldx tmp2
    jmp restart_plotting_chars
.)

tmpt = (foreground+framemask) * 8 + charset
tmpt1 = (foreground+framemask+1) * 8 + charset
tmpt2 = (foreground+framemask+2) * 8 + charset

rotate_bricks:
.(
    lda #<tmpt2         ; Point to first brick in charset.
    sta sl
    lda #>tmpt2
    sta sl+1

    ldx #0
l1: cpx active_bricks
    beq rotate_trailing_chars
    lda sl              ; Set pointer to middle char.
    clc
    adc #8
    sta sm
    lda sl+1
    clc
    adc #0
    sta sm+1

    lda bricklist_r,x   ; Set pointer to right char.
    beq n3
    cmp #<background
    bne n4
    lda #framemask+foreground
    jmp n3
n4: cmp #<bg_t
    bne n3
    lda #framemask+foreground+1
n3: jsr get_char_addr
    lda d
    sta sr
    lda d+1
    sta sr+1

    ldy #7              ; Rotate.
l:  lda (sr),y
    rol
    sta tmp
    lda (sm),y
    rol
    sta tmp2
    lda (sl),y
    rol
    sta tmp3
    lda tmp
    asl
    lda tmp2
    rol
    sta (sm),y
    lda tmp3
    rol
    sta (sl),y
    dey
    bpl l

    lda sl          ; Step to next brick in charset.
    clc
    adc #16
    sta sl
    lda sl+1
    clc
    adc #0
    sta sl+1
    inx
    jmp l1

rotate_trailing_chars:
    lda #<tmpt
    sta s
    lda #>tmpt
    sta s+1
    ldy #15
l2: lda (s),y
    asl
    adc #0
    asl
    adc #0
    sta (s),y
    dey
    bpl l2
    rts
.)
