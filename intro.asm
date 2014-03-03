intro:
    jsr clear_screen
    lda #8+blue     ; Screen and border.
    sta $900f
    lda #red*16     ; Auxiliary color.
    sta $900e
    lda #%11111100  ; Our charset.                                              
    sta $9005

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

.(
    ldx #7
    lda #48
l:  sta hiscore,x
    dex
    bpl l
.)
#endif

    jmp game_over

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
