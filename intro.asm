intro:
.(
    ldx #203
l:  lda #" "
    sta screen-1,x
    sta screen+202,x
    lda #white
    sta colors-1,x
    sta colors+202,x
    dex
    bne l
.)

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

    lda #%11111100  ; Our charset.                                              
    sta $9005

.(
    ldx #7
    lda #48
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

#ifdef ARCADE_ROMANCE
.(
    lda #0
    tax
l:  sta 0,x
    sta charset,x
    sta charset+$100,x
    dex
    bne l
.)

    ldy #0
    sty foregroundmask+1
    iny
    sty foregroundtest+1
    sty next_sprite_char
    lda #63
    sta charsetmask

introloop:
.(
    lda #200
    sta counter
l:  lda counter
    and #7
    sta curcol
    lda #0
    sta x0
    lda counter
    sta y0
    lda #171
    sta x1
    lda #10
    clc
    adc counter
    sta y1
    jsr draw_line
    dec counter
    bne l
.)
#endif

#ifdef DRAW_PIXEL
draw_pixel:
.(
    txa
    pha
    lsr
    lsr
    lsr
    sta scrx
    tya
    pha
    lsr
    lsr
    lsr
    sta scry
    txa
    and #7
    sta repetition
    tya
    and #7
    sta tmp2
    jsr get_char
    lda d+1
    beq done
    ldx repetition
    lda bits,x
    ldy tmp2
    ora (d),y
    sta (d),y
done:
    pla
    tay
    pla
    tax
    rts
.)
#endif

story:
.asc "Our enemies now attack   us from the 20th   dimension! We hastily created a drone remotecontrol software. "
.asc "You  are one of the last  pilots with the right hardware to use it out there. "
.asc "We don't know   what to expect. We      count on you.      Good luck! Hit fire!", 0
