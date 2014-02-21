line_ycnt:  .byte 0
line_counter:   .byte 0
dx2:        .byte 0
dxy:        .byte 0

draw_line:
.(
    lda x1      ; dx = x1 - x0
    sec
    sbc x0
    sta dx
    sta line_counter
    asl
    sta dx2

    lda y1      ; dy = y1 - y0
    sec
    sbc y0
    asl
    sta dy

    sec         ; D = 2*dy - dx
    sbc dx
    sta line_d

    lda dy
    sec
    sbc dx2
    sta dxy

    lda x0
    and #7
    tax
    lda bits,x
    sta line_pixelbit+1

    lda y0
    and #7
    sta line_charline+1
    lda #7
    sec
    sbc line_charline+1
    sta line_ycnt

    lda x0
    lsr
    lsr
    lsr
    sta scrx
    lda y0
    lsr
    lsr
    lsr
    sta scry
    jsr get_char

loop:
    lda d+1
    beq dont_plot
line_charline:
    ldy #0
line_pixelbit:
    lda #0
    ora (d),y
    sta (d),y
dont_plot:
    dec line_counter
    beq done
    lsr line_pixelbit+1
    bcs next_column
continue_column:
    lda line_d
    beq n1      ; D = 0
    bmi n1      ; D < 0
    inc line_charline+1
    dec line_ycnt
    bmi next_row
continue_row:
    lda dxy
    jmp add_to_d
n1: lda dy      ; D = D + 2dy
add_to_d:
    clc
    adc line_d
    sta line_d
    jmp loop
next_column:
    inc scrx
    lda #128
    sta line_pixelbit+1
    jsr get_char
    jmp continue_column
next_row:
    inc scry
    lda #7
    sta line_ycnt
    lda #0
    sta line_charline+1
    jsr get_char
    jmp continue_row
done:
    rts
.)
