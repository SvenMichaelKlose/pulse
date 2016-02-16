screen_columns = 22

    org $80

    data
bars_probability:   0
counter:            0
s:                  0 0
d:                  0 0
last_random_value:  0
    end

    org $1000

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

intro_message:
    ldx #$ff
    txs
    lda #@(/ (- 71 8) 5)
    sta @(++ mod_line)
    lda $ede4
    cmp #5
    beq +n
    lda #@(/ (- 65 8) 5)
    sta @(++ mod_line)
n:

    ; Boost digital audio with distorted HF carrier.
    lda #$0f
    sta $900e
    ldx #$7e
    stx $900c
    ldy #0
l:  dey
    bne -l
    lda #$fe
    stx $900c
    stx $900c
    sta $900c
    sta $900c
    stx $900c
    sta $900c

    ldy #<loader_cfg_8k
    lda #>loader_cfg_8k
    jsr tape_loader_start

    lda #$ff
    sta bars_probability

    jsr clear_screen

    dec $9001
    dec $9001
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
    and bars_probability
    beq +e
    jsr random
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
mod_line:
    ldx #@(/ (- (? (eq *tv* :pal) 65 71) 8) 5)
t:  dex
    bne -t
    dec counter
    bne -a
    lsr bars_probability
    bne -a

next_part:
    lda #$19
    sta $900f
    jsr clear_screen

    jmp @*sun-start*

init_8k:
    ; Stop tape motor.
    lda $911c
    ora #2
    sta $911c

    jmp $eb18

clear_screen:
    ldx #253
l:  lda #32
    sta @(-- screen),x
    sta @(+ screen 252),x
    dex
    bne -l
    rts

patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_8k:
    $00 $20
    <patch_8k_size @(++ >patch_8k_size)
    <init_8k >init_8k
