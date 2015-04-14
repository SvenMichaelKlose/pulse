grenade_center:
    0

start_grenade:

    lda @(+ sprites_x 15)
    lsr
    lsr
    lsr
    sta grenade_center
    jmp draw_grenade

end_grenade:
    lda #0
    sta grenade_counter                                           
    rts

grenade:
    lda grenade_counter
    beq +done
    cmp #22
    bcs end_grenade

draw_grenade:
    ldy #14
l:  tya
    pha
    lda sprites_i,y
    and #decorative
    bne +n
    jsr explode
n:  pla
    tay
    dey
    bpl -l
    inc grenade_counter

    lda grenade_center
    clc
    adc grenade_counter
    sta scrx
    lda #0
    jsr grenade_bar
    inc scrx
    lda #128
    jsr grenade_bar

    lda grenade_center
    sec
    sbc grenade_counter
    sta scrx
    lda #128
    jsr grenade_bar
    inc scrx
    lda #0

grenade_bar:
    sta @(++ grenade_bar_color)
    lda #22
    sta scry
l:  jsr scrcoladdr
    cpy #22
    bcs +done
    lda (scr),y
    and #foreground
    cmp #foreground
    beq +n
grenade_bar_color:
    lda #0
    sta (scr),y
    lda #white
    sta (col),y
n:  dec scry
    bpl -l
done:
    rts
