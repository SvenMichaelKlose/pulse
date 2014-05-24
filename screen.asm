scraddr:
    ldy scry
    lda $edfd,y
    sta scr
    lda #>screen
    ora line_offsets_h,y
    sta scr+1
    ldy scrx
    rts

scrcoladdr:
    ldy scry
    lda $edfd,y
    sta scr
    sta col
    lda #>screen
    ora line_offsets_h,y
    sta scr+1
    lda #>colors
    ora line_offsets_h,y
    sta col+1
    ldy scrx
    rts

line_offsets_h:
    .byte >0, >22*1, >22*2, >22*3, >22*4, >22*5, >22*6, >22*7, >22*8, >22*9, >22*10, >22*11, >22*12, >22*13, >22*14, >22*15, >22*16, >22*17, >22*18, >22*19, >22*20, >22*21, >22*22
