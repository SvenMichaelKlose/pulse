startloop:
    jsr clear_screen

.(
    ldx #numchars-1
l1: txa
    sta screen+17*22,x
    dex
    bpl l1
.)

.(
    lda #0
    sta sprbank
    ldx #7
l1: sta chars,x
    dex
    bpl l1
.)

.(
    lda #0
    ldx #15
l1: sta sprites_ox,x
    sta sprites_oy,x
    dex
    bpl l1
.)

    lda #0
    sta tmp3

mainloop:
    inc tmp3
    lda tmp3
    sta tmp2
    lda #0
    sta tmp

.(
    ldx #0
l1: lda tmp
    sta sprites_x,x
    lda tmp2
    and #127
    sta tmp2
    sta sprites_y,x
    lda #<spr1
    sta sprites_l,x
    lda #>spr1
    sta sprites_h,x
    txa
    and #7
    sta sprites_c,x
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp
    inc tmp2
    inc tmp2
    inc tmp2
    inx
    cpx #$0f
    bne l1
.)
    lda #0
    sta sprites_h,x

    jsr frame
    jmp mainloop
