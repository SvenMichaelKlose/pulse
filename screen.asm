screen_h = >screen

; Calculate line address in screen memory.
scraddr:
    ldy scry
    lda $edfd,y         ; Get low line address.
    sta scr
    cpy #12             ; Set carry flag if above line 11.
    lda #screen_h/2     ; Take screen page shifted 1 to the right...
    rol                 ; ... and roll in carry flag to add it.
    sta scr+1
    ldy scrx
    rts

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
