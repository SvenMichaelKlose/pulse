    org $1000
    $02 $10

    jmp start

    0 0 0
    @(subseq *earth-chars* 8 (* 15 8))

start:
    ; Wait for retrace.
l:  lsr $9004
    bne -l

    lda #@(+ 128 22)
    sta $9002
    lda #$fc            ; Screen at $1e00, charset at $1000.
    sta $9005
    lda #reverse
    sta $900f

    ; Clear the screen.
    ldx #253
    lda #0
l:  sta @(-- screen),x
    sta @(+ 252 screen),x
    dex
    bne -l

    ; Clear first char.
    ldx #4
l:  sta $1000,x
    dex
    bpl -l

    sta chunks_loaded
    sta last_loaded_chunk
