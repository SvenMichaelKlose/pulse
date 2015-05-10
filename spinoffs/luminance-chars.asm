    sei         ; Disable interrupts.
    lda #$7f
    sta $911e   ; Disable interrupts in VIA1.
    sta $911d   ; Disable interrupts in VIA1.
    sta $912e   ; Disable interrupts in VIA2.
    sta $912d   ; Disable interrupts in VIA1.
    lda #%11000000
    sta $912e   ; Disable interrupts in VIA2.

    ; Set screen dimensions.
    lda #@(+ 128 16)
    sta $9002
    lda #@(* 16 2)
    sta $9003
    lda #$fd
    sta $9005
    lda #8
    sta $900f

    ldx #0
    lda #white
l:  sta colors,x
    sta @(+ 203 colors),x
    dex
    bne -l

    ldx #63
    ldy #64
l:  lda luminances,x
    sta $1400,x
    eor #$ff
    sta $1400,y
    iny
    dex
    bpl -l

    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    jmp @ohne_dich

luminances:
l0:
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111
    %11111111

l1:
    %11111111
    %11111111
    %11111111
    %01010101
    %11111111
    %11111111
    %11111111
    %01010101

l2:
    %11111111
    %01010101
    %11111111
    %11111111
    %01010101
    %11111111
    %11111111
    %01010101

l3:
    %11111111
    %01010101
    %11111111
    %01010101
    %11111111
    %01010101
    %11111111
    %01010101

l4:
    %11111111
    %01010101
    %01010101
    %01010101
    %11111111
    %01010101
    %11111111
    %01010101

l5:
    %01010101
    %01010101
    %11111111
    %01010101
    %01010101
    %01010101
    %11111111
    %01010101

l6:
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %11111111
    %01010101
    %01010101

l7:
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
    %01010101
