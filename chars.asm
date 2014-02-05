alloc_char:
.(
    lda sprchar     ; Pick fresh one from top.
    inc sprchar     ; Increment for next allocation.
    and #%01111111  ; Avoid hitting code.
    pha             ; Delay screen write to reduce artifacts.
    jsr get_char_addr
    tya             ; Clear the new char.
    ldy #7
l3: sta (d),y
    dey
    bpl l3
    pla
    rts
.)

; Get or allocate a bitmap char.
get_char:
.(
    jsr scrcoladdr
    ldy #0
    lda (scr),y
    beq l2
    tax
    and #sprbufmask
    cmp sprbank
    beq get_char_addrx
l2: jsr alloc_char
    iny
    sta (scr),y
    lda curcol
    sta (col),y
    rts
.)

get_char_addrx:
    txa

    ; Get char address.
get_char_addr:
    clc
    rol
    adc #0
    rol
    adc #0
    rol
    adc #0
    tax
    and #%11111000
    sta d
    txa
    and #%00000111
    ora #>chars
    sta d+1
    rts

; Remove char if it's not in the current bank.
clear_char:
.(
    jsr scraddr
    ldy #0
    lda (scr),y
    beq e1
    and #sprbufmask
    cmp sprbank
    beq e1
    tya
    sta (scr),y
e1: rts
.)
