hide_screen:
    jsr wait_for_screen_bottom
    lda #0
    sta $9003
    rts

show_screen:
    jsr wait_for_screen_bottom
    lda @(+ #xede4 3)
    sta $9003
    rts

set_text_mode:
    lda #reverse        ; Screen and border color.
    sta $900f
    lda #%11110010      ; Up/locase chars.
    sta $9005
    rts

wait_for_screen_bottom:
    ; Avoid screen trash
    lda #@(? (eq *tv* :pal) 150 120)
l:  cmp $9004
    bne -l
    rts

clear_screen:
    ldx #253
l:  lda #32                                                                                            
    sta @(-- screen),x
    sta @(+ screen 252),x
    lda #0
    sta @(-- colors),x
    sta @(+ colors 252),x
    dex
    bne -l
    rts

wait:
l:  lsr $9004
    bne -l
m:  lsr $9004
    beq -m
    dex
    bne -l
    rts

strout:
    jsr strchrout
    bne strout
    rts

strchrout:
    ldy #0
    lda (s),y
    beq +done
    jsr chrout
    jsr inc_s
    cmp #32
    beq strchrout
    lda #1
done:
    rts
    
chrout:
    cmp #255
    bne +n
    lda #0
    sta scrx
    inc scry
    rts
n:  pha
    jsr scrcoladdr
    pla
    pha
    sta (scr),y
    lda curcol
    sta (col),y
    inc scrx
    pla
    rts

scrcoladdr:
    ldy scry
    lda $edfd,y
    sta scr
    sta col
    cpy #12
    lda #@(half (high screen))
    rol
    sta @(++ scr)
    and #1
    ora #@(high colors)
    sta @(++ col)
    ldy scrx
    rts

inc_s:
    inc s
    bne +done
    inc @(++ s)
done:
    rts
