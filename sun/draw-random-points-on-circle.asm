draw_random_point_on_circle:
    jsr random
    and #63
    ora #64
    sta degrees
    and #$0f
    ora #@(* light_yellow 16)
    sta $900e
    jsr point_on_circle
    stx tmpx
    sty tmpy

    txa
    clc
    adc cxpos
    tax
    tya
    clc
    adc cypos
    tay
    jsr draw_pixel

    lda cxpos
    clc
    adc tmpx
    tax
    lda cypos
    sec
    sbc tmpy
    tay
    jsr draw_pixel

    lda cxpos
    sec
    sbc tmpx
    tax
    lda cypos
    sec
    sbc tmpy
    tay
    jsr draw_pixel

    lda cxpos
    sec
    sbc tmpx
    tax
    lda cypos
    clc
    adc tmpy
    tay
    jsr draw_pixel

    rts
