screen_h = >screen

; Calculate line address in screen and colour memory.
scrcoladdr:
    ldy scry
    lda $edfd,y
    sta scr
    sta col
    cpy #12
    lda #@(half screen_h)
    rol
    sta @(++ scr)
    and #1
    ora #>colors
    sta @(++ col)
    ldy scrx
    rts
