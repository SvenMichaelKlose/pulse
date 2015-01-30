screen_h = >screen

; Calculate line address in screen and colour memory.
scrcoladdr:
    ldy scry
    lda $edfd,y
    sta scr
    sta col
    cpy #12
    lda #screen_h/2
    rol
    sta scr+1
    and #1
    ora #>colors
    sta col+1
    ldy scrx
    rts
