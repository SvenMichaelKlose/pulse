grenade:
    lda grenade_counter
    beq +done
    dec grenade_counter

draw_grenade:
    ; Kill everything deadly.
    ldy #14
l:  tya
    pha
    lda sprites_i,y
    and #deadly
    beq +n
    jsr explode
n:  pla
    tay
    dey
    bpl -l

    jsr random
    and #%111
    clc
    adc #32
    sta $9001
    ora #128
    sta $900d

    dec grenade_left
    inc grenade_right

    lda grenade_left
    sta scrx
    lda #64
    jsr grenade_bar
    lda #0
    jsr grenade_bar

    lda grenade_right
    sta scrx
    lda #0
    jsr grenade_bar
    lda #64

grenade_bar:
    sta @(++ grenade_bar_color)
    lda #22
    sta scry
l:  jsr scrcoladdr
    cpy #22
    bcs +done
    jsr test_on_foreground
    beq +n          ; Don't draw over foreground…
grenade_bar_color:
    lda #0
    sta (scr),y
    lda #white
    sta (col),y
n:  dec scry
    bpl -l
done:
    inc scrx
    rts
