    org $1000
    $02 $10

    jmp start

    0 0 0
    @(subseq *earth-chars* 8 (* 15 8))

start:
    ; Wait for retrace.
l:  lsr $9004
    bne -l

    ; Charset at $1000.
    lda #%11111100
    sta $9005

    ; Clear the screen.
    ldx #252
    lda #0
l:  sta screen,x
    sta @(+ 253 screen),x
    dex
    bne -l

    ; Clear first char.
    ldx #4
l:  sta $1000,x
    dex
    bpl -l

    sta chunks_loaded
    sta last_loaded_chunk
