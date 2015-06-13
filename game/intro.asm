    ; Reset highscore.
    ldx #7
    lda #score_char0
l:  sta hiscore,x
    dex
    bpl -l

intro:
if @*coinop?*
    lda #<start_game
    sta $a000
    lda #>start_game
    sta $a001
    lda #1              ; Enable coin interrupt.
    sta $a002
end
    ldx #0
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
if @*virtual?*
    lda #<story
    sta @(+ +l 1)
    lda #>story
    sta @(+ +l 2)
    lda #@(low (+ screen (* 5 screen_width)))
    sta @(+ +l2 1)
    lda #@(high (+ screen (* 5 screen_width)))
    sta @(+ +l2 2)
end
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
l:
if @(not *coinop?*)
    lda #0
    sta $9113
    lda $9111
    and #%00100000
    beq +start_game ; Fire…
end
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
    adc #@(? (eq *tv* :pal) 38 21)
    sta $9001
    bne -l

e:  lda #@(+ white 8 (* 16 white))
    sta $900f
    ldx #@(/ (- (? (eq *tv* :pal) 65 71) 8) 5)
t:  dex
    bne -t
if @*virtual?*
    $22 2
end
    jmp -a

start_game:
    lda #%11111100          ; Our charset.
    sta $9005
    lda #@(+ reverse blue)  ; Screen and border color.
    sta $900f

    jmp game_over

story:
    @(petscii-story) 0
