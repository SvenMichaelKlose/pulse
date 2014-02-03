; Get or allocate a bitmap char.
get_char:
.(
    jsr scraddr
    ldy #0
    lda (scr),y
    beq l2
    tax
    and #%01000000
    cmp sprbank
    bne l2
    txa
    jmp l1
l2: lda sprchar     ; Pick fresh one from top.
    and #%01111111  ; Avoid hitting code.
    pha             ; Delay screen write to reduce artifacts.
    inc sprchar     ; Increment for next allocation.
    jsr l1          ; Get char address.
    tya             ; Clear the new char.
    ldy #7
l3: sta (sprbits),y
    dey
    bpl l3
    iny
    pla             ; Put char on screen.
    sta (scr),y
    lda curcol
    sta (col),y
    rts

    ; Get char address.
l1: clc
    rol
    adc #0
    rol
    adc #0
    rol
    adc #0
    tax
    and #%11111000
    sta sprbits
    txa
    and #%00000111
    ora #>chars
    sta sprbits+1
    rts
.)

; Remove char if it's not in the current bank.
clear_char:
.(
    jsr scraddr
    ldy #0
    lda (scr),y
    beq e1
    and #bankmask
    cmp sprbank
    beq e1
    tya
    sta (scr),y
e1: rts
.)
