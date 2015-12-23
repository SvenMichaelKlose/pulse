scraddr:
    ldy scry
    lda screenlines_l,y
    sta scr
    lda screenlines_h,y
    sta @(++ scr)
    ldy scrx
    rts

screenlines_l: @(maptimes [low (+ screen (* screen_columns _))] screen_rows)
screenlines_h: @(maptimes [high (+ screen (* screen_columns _))] screen_rows)
