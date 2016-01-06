draw_random_point_on_circle:
    jsr random
    and #63
    ora #64
    sta degrees
    and #$0f
    ora #@(* light_yellow 16)
    sta $900e
    lda #0
    sta xpos
    sta ypos
    jsr point_on_circle
    stx tmpx
    sty tmpy

    txa
    clc
    adc #@(half screen_columns)
    tax
    tya
    clc
    adc #@(half screen_rows)
    tay
    jsr draw_pixel

    lda #@(half screen_columns)
    clc
    adc tmpx
    tax
    lda #@(half screen_rows)
    sec
    sbc tmpy
    tay
    jsr draw_pixel

    lda #@(half screen_columns)
    sec
    sbc tmpx
    tax
    lda #@(half screen_rows)
    sec
    sbc tmpy
    tay
    jsr draw_pixel

    lda #@(half screen_columns)
    sec
    sbc tmpx
    tax
    lda #@(half screen_rows)
    clc
    adc tmpy
    tay
    jsr draw_pixel

    rts
