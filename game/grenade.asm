grenade:
    lda grenade_counter
    beq +done
    dec grenade_counter

draw_grenade:
    ; Kill everything deadly.
    ldy #14
l:  sty draw_grenade_y
    lda sprites_i,y
    and #deadly
    beq +n
    lda formation_left_unhit
    clc
    adc adding_scout
    cmp #6
    bne +e
    jsr make_bonus
    jmp +n
e:  jsr explode
n:  ldy draw_grenade_y
    dey
    bpl -l

    jsr random
    and #%111
    clc
    adc #@(? (eq *tv* :pal) 38 21)
    sta $9001
    ora #128
    sta $900a
    sta $900d

    dec grenade_left
    inc grenade_right

    lda grenade_left
    sta scrx
    lda #64
    jsr grenade_bar
    lda #0
    sta formation_left_unhit
    jsr grenade_bar

    lda grenade_right
    sta scrx
    lda #0
    jsr grenade_bar
    lda #64

grenade_bar:
    sta @(++ grenade_bar_color)
    lda #@(-- screen_rows)
    sta scry
l:  jsr scrcoladdr
    cpy #screen_columns
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
