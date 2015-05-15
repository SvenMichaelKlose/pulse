intro:
    ldy #green
l:  lda #32
    sta @(-- screen),x
    sta @(+ screen 252),x
    dex
    bne -l

    lda #@(* red 16)    ; Auxiliary color.
    sta $900e
    lda #%11110010      ; Up/locase chars.
    sta $9005

    ; Copy story to screen.
    ldx #0
l:  lda story,x
    beq +e
l2: sta @(+ screen (* 5 screen_width)),x
    inx
    bne -l
    inc @(+ -l 2)
    inc @(+ -l2 2)
    jmp -l
e:

a:  lda #@(+ 8 black)   ; Screen and border color.
    sta $900f
    lda #0
    sta s
    sta d
    ldy #>colors
    sty @(++ s)
    iny
    sty @(++ d)
l:  lda #0
    sta $9113
    lda $9111
    and #%00100000
    beq +n ; Fire…
    jsr random
    beq +e
    sta $900e
    lsr
    lda #white
    bcc +f
    lda #green
f:  sta (s),y
    sta (d),y
    iny
    jsr random
    and #%1
    clc
    adc #32
    sta $9001
    jmp -l

e:  lda #@(+ white 8 (* 16 white))
    sta $900f
    ldx #@(/ 64 5)    ; XXX pal or ntsc
t:  dex
    bne -t
    beq -a

n:  lda #%11111100      ; Our charset.
    sta $9005
    lda #@(+ 8 blue)    ; Screen and border color.
    sta $900f

    ; Reset highscore.
    ldx #7
    lda #score_char0
l:  sta hiscore,x
    dex
    bpl -l

    jmp game_over

story:
    @(petscii-story) 0
