radio_timer = @(/ (cpu-cycles *tv*) (half (radio-rate *tv*)))

flight:
    lda #<radio_timer
    sta $9114
    lda #>radio_timer
    sta $9115
    lda #$40
    sta $911b
    lda #0
    sta rr_sample
    sta do_play_radio
l:  lda do_play_radio
    beq -l
l:  lda $911d
    asl
    bmi play_sample
c:  jmp -l

play_sample:
    ldx rr_sample
mod_sample_getter:
    lda sample_buffer,x
    sta $900e
    dex
    stx rr_sample
    lda #>radio_timer
    sta $9115
    lda #$7f
    sta $911d
    jmp -c

draw_object:
l:

    ; Fetch pixel position.
    ldy #0
    lda (s),y
    bmi +done
    sta scrx
    iny
    lda (s),y
    sta scry
    inc s
    inc s
    bne +n
    inc @(++ s)

n:  ldx scry
    cpx screen_columns
    bcc -l          ; off–screen…
    ldy scrx
    cpy screen_rows
    bcc -l          ; off–screen…
    lda scrlines_l,x
    sta scr
    lda scrlines_h,x
    sta @(++ scr)
    lda collines_l,x
    sta col
    lda collines_h,x
    sta @(++ col)

    lda curchar
    sta (scr),y
    lda curcol
    sta (col),y
    jmp -l
done: rts

scrlines_l: @(maptimes [low (+ #x1e00 (* 22 _))] 23)
scrlines_h: @(maptimes [high (+ #x1e00 (* 22 _))] 23)
collines_l: @(maptimes [low (+ #x9600 (* 22 _))] 23)
collines_h: @(maptimes [high (+ #x9600 (* 22 _))] 23)
