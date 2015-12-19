    org $1000
    $02 $10

    jmp start

    fill @(* 6 8)

chars:
    $00 $00 $00 $00 $00 $00 $00 $00
    $AA $AA $AA $AA $AA $AA $AA $AA
    $AA $00 $AA $00 $AA $00 $AA $00
    $FF $FF $FF $FF $FF $FF $FF $FF
    $FF $00 $FF $00 $FF $00 $FF $00
    $00 $00 $00 $00 $00 $00 $00 $00
chars_end:

start:
    ; Wait for retrace.
l:  lsr $9004
    bne -l

    ; Charset at $1000.
    lda #%11111100
    sta $9005

    ; Copy character data to $1000.
    ldx #@(- chars_end chars)
l:  lda chars,x
    sta $1000,x
    dex
    bpl -l

    ; Clear the screen.
    ldx #252
    lda #0
l:  sta screen,x
    sta @(+ 253 screen),x
    dex
    bne -l
