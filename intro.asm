intro:
    ldy #white
    jsr clear_screen_and_colors

    lda #8+blue     ; Screen and border color.
    sta $900f
    lda #red*16     ; Auxiliary color.
    sta $900e
    lda #%11110010  ; Up/locase chars.
    sta $9005
    lda #<story
    sta d
    lda #>story
    sta d+1

.(
    ldx #0
l:  lda story,x
    beq e
    jsr ascii2petscii
l2: sta screen+5*22,x
    inx
    bne l
    inc l+2
    inc l2+2
    jmp l
e:
.)

.(
l:  lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    and #%00100000
    bne l
.)

    ; Avoid screen trash.
    ldy #black
    jsr clear_screen_and_colors

    lda #%11111100      ; Our charset.
    sta $9005

    ; Reset highscore.
.(
    ldx #7
    lda #score_char0
l:  sta hiscore,x
    dex
    bpl l
.)

    jmp game_over

ascii2petscii:
.(
    cmp #"X"+2
    bcc done
    sec
    sbc #"a"-1
done:
    rts
.)

clear_screen_and_colors:
.(
    ldx #203
l:  lda #" "
    sta screen-1,x
    sta screen+202,x
    tya
    sta colors-1,x
    sta colors+202,x
    dex
    bne l
    rts
.)

story:
.asc "Our enemies now attack   us from the 20th   dimension! We hastily created a drone remotecontrol software. "
.asc "You  are one of the last  pilots with the right hardware to use it out there. "
.asc "We don't know   what to expect. We      count on you.      Good luck! Hit fire!", 0
