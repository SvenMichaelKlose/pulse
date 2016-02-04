hiscore_table:
    ldx #$ff
    txs
    jsr hide_screen
    jsr set_text_mode
    jsr clear_screen

    lda #0
    sta framecounter

    jsr show_screen
    ldx #0
l:  lda #white
    sta colors,x
    sta @(+ 256 colors),x
    dex
    bne -l

    ldx #@(-- txt_fame_len)
l:  lda txt_fame,x
    sta @(+ screen (half (- 22 txt_fame_len))),x
    dex
    bpl -l

loop:
    ldx #1
    jsr wait

    ; Draw hiscore table.
    lda #<hiscores
    sta s
    lda #>hiscores
    sta @(++ s)
    lda #2
    sta scry

l:  lda #4
    sta scrx
    lda #@(-- num_score_digits)
    jsr nstrout

    lda #14
    sta scrx
    lda #@(-- num_name_digits)
    jsr nstrout

    inc scry
    inc scry
    lda scry
    cmp #21
    bcc -l

    lda hiscore_entry
    bne +edit

    dec framecounter
    bne -loop
    jmp reenter_title

edit:
    ; Edit new entry.
    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #joy_fire
    bne no_fire

no_fire:
    ; Joystick up.
n:  tya
    and #joy_up
    bne +n

    ; Joystick down.
n:  tya
    and #joy_down
    bne +n

    ; Joystick left.
n:  tya
    and #joy_left
    bne +n

    ; Joystick right.
n:  lda #0          ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi -loop

    rts

nstrout:
    pha
    jsr scrcoladdr
    tya
    clc
    adc scr
    sta scr
    bcc +n
    inc @(++ scr)
n:

    pla
    pha
    tay
l:  lda (s),y
    sta (scr),y
    dey
    bpl -l

    pla
    sec
    adc s
    sta s
    bcc +n
    inc @(++ s)
n:

    rts

txt_fame:
    @(ascii2petscii "Hall Of Fame")
txt_fame_end:
txt_fame_len = @(- txt_fame_end txt_fame)

hiscores:
    @(apply #'nconc (maptimes [+ (maptimes [identity #\0] num_score_digits)
                                 (maptimes [identity #\A] num_name_digits)]
                              num_hiscore_entries))
