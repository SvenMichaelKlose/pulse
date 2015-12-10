flight:
    lda $9003
    asl
    lda $9004
    rol
    sta last_audio_raster
    lda #0
    sta rr_sample
    sta do_play_radio
l:  lda do_play_radio
    beq -l
l:  jsr play
    jmp -l

play:
    lda $9003
    asl
    lda $9004
    rol
    tay
    sec
    sbc last_audio_raster
    cmp #@(radio-rasters)
    bcs +n
    rts

n:  sty last_audio_raster
    ldx rr_sample
mod_sample_getter:
    lda sample_buffer,x
    sta $900e
    dex
    stx rr_sample
    rts

draw_object:
l:  jsr play

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
