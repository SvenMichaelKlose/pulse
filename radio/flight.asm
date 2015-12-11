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
    

scrlines_l: @(maptimes [low (+ #x1e00 (* 22 _))] 23)
scrlines_h: @(maptimes [high (+ #x1e00 (* 22 _))] 23)
collines_l: @(maptimes [low (+ #x9600 (* 22 _))] 23)
collines_h: @(maptimes [high (+ #x9600 (* 22 _))] 23)

zoomtabs:
    @(apply #'nconc
            (print (maptimes [alet (- 22 _)
                        (append (maptimes [integer (* _ (/ 22 !))] !)
                                (list 255))]
               22)))

