blit_left_whole_char:
    ldy #7
blit_left:
.(
    sta s
    lda #8
    clc
    sbc blitter_shift_left
    sta s3+1
l1: lda (s),y
    clc
s3: bcc s1
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
s1: ora (d),y
    sta (d),y
    dey
    bpl l1
    rts
.)

blit_right_whole_char:
    ldy #7
blit_right:
.(
    sta s
    lda #8
    clc
    sbc blitter_shift_right
    sta s3+1
l1: lda (s),y
    clc
s3: bcc s1
    asl
    asl
    asl
    asl
    asl
    asl
    asl
s1: ora (d),y
    sta (d),y
    dey
    bpl l1
    rts
.)
