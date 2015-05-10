main:
    sei         ; Disable interrupts.
    lda #$7f
    sta $911e
    sta $911d
    sta $912e
    sta $912d

    ; Print text.
l:  lda @text,x
    beq +n
    jsr $ffd2
    inx
    bne -l
    inc @(+ -l 2)
    jmp -l
n:
