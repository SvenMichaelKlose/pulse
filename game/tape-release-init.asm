realstart = @(+ #x1000 charsetsize)

main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    ; Init +8K patch.
    lda model
    lsr
    beq +n
    jsr $2002
n:

    ; Copy code to $200-3ff.
    ldx #0
l:  lda @(- stackmem 128),x
    sta $100,x
    lda lowmem,x
    sta $200,x
    lda @(+ lowmem #x100),x
    sta $300,x
    dex
    bne -l

    ; Reset highscore.
    ldx #7
    lda #score_char0
l:  sta hiscore,x
    dex
    bpl -l

    lda #%11111100          ; Our charset.
    sta $9005
    lda #@(* red 16)    ; Auxiliary color.
    sta $900e
    lda #@(+ reverse blue)  ; Screen and border color.
    sta $900f
    jmp game_over
