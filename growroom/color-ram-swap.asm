; Swap all color RAM with 256 bytes of real RAM.

color_swapped = game_over

color_ram_swap:
    ; Set color RAM pointer.
    ldy #0
    sty d
    lda #>colors
    sta @(++ d)

    ; First run with rotated bytes.
    lda #4
    jsr +i

    ; Second run with effectively no rotation.
    lda #8

    ; Set pointer to swapped area in real RAM.
i:  sta @(++ +r)
    sty s
    lda #>color_swapped
    sta @(++ s)

    ; Fetch byte from real RAM and rotate it.
r:  ldx #4
    lda (s),y
    clc
l:  rol
    adc #0
    dex
    bne -l

    ; Break up byte into nibbles.
lower_nibble = tmp
upper_nibble = tmp2
    sta lower_nibble
    and #$f0
    sta upper_nibble

    ; Commbine upper nibble with new lower nibble from color RAM.
    lda (d),y
    and #$0f
    ora upper_nibble
    sta (s),y

    ; Save old lower nibble in color RAM.
    lda lower_nibble
    sta (d),y

    ; Step to next nibble.
    iny
    bne -r

    rts
