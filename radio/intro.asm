screen_columns  = 22
screen_rows  = 23

    org $1000
    $02 $10

    lda #@(+ reverse black) ; Screen and border color.
    sta $900f
    jsr clrscr
l:  lda $9004
    bne -l
    lda #148        ; Unblank screen. 20 columns.
    sta $9002
    lda #%11110010      ; Up/locase chars.
    sta $9005

    ; Load +3K RAM
    ldx #5
l:  lda loader_cfg_3k,x
    sta tape_ptr,x
    dex
    bpl -l

    jmp tape_loader_start

patch_3k_size = @(length (fetch-file (+ "obj/3k.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_3k:
    $00 $10
    <patch_3k_size @(++ >patch_3k_size)
    $02 $10

txt_eyes:
    @(ascii2petscii "East") 255
    @(ascii2petscii "Yorkshire") 255
    @(ascii2petscii "Engineering") 255
    @(ascii2petscii "Software") 255 0

intro:
    jsr clrscr

    lda #@(* red 16)    ; Auxiliary color.
    sta $900e
    lda #%11110010      ; Up/locase chars.
    sta $9005

    ; Copy story to screen.
    ldx #0
l:  lda story,x
    beq +e
l2: sta @(+ screen (* 5 screen_columns)),x
    inx
    bne -l
    inc @(+ -l 2)
    inc @(+ -l2 2)
    bne -l              ; (JMP)
e:

a:  lda #@(+ reverse black) ; Screen and border color.
    sta $900f
    lda #0
    sta s
    sta d
    ldy #>colors
    sty @(++ s)
    iny
    sty @(++ d)
l:  jsr random
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
    adc $ede5
    sta $9001
    bne -l

e:  lda #@(+ white 8 (* 16 white))
    sta $900f
    ldx #@(/ (- (? (eq *tv* :pal) 65 71) 8) 5)
t:  dex
    bne -t
    beq -a      ; (JMP)

done:
    jmp done

story:
    @(ascii2petscii
       "Our enemies now attack"
       "   us from the 20th   "
       "dimension! We hastily "
       "created a drone remote"
       "control software. You "
       " are one of the last  "
       "pilots with the right "
       "hardware to use it out"
       " there. We don't know "
       "  what to expect. We  "
       "    count on you.     "
       " Good luck! Hit fire!")
    0

clrscr:
    ldx #253
l:  lda #32
    sta @(-- screen),x
    sta @(+ screen 252),x
    lda #white
    sta @(-- colors),x
    sta @(+ colors 252),x
    dex
    bne -l
    rts
