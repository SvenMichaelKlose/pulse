; Calculate line address in screen and colour memory.
block
scrcoladdr:
    ldy scry
    lda $edfd,y
    sta scr
    sta col
    cpy #@(++ (/ 256 screen_columns))
    lda #@(half (high screen))
    rol
    sta @(++ scr)
    and #1
    ora #>colors
    sta @(++ col)
    ldy scrx
    rts
end block
