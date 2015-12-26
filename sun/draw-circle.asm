draw_random_point_on_circle:
    jsr random
    sta degrees
    and #$0f
    ora #@(* light_yellow 16)
    sta $900e
    lda #@(half screen_columns)
    sta xpos
    lda #@(half screen_rows)
    sta ypos
    jsr point_on_circle
    jsr draw_pixel
    rts
