alloc_squeeze:
    lda sprbank
    ora #1
    jmp fetch_char

alloc_char:
.(
    lda sprchar     ; Pick fresh one from top.
    tax
    and #framechars/2+framechars/4
    cmp #framechars/2+framechars/4
    beq alloc_squeeze
    txa
    inc sprchar     ; Increment for next allocation.
.)

fetch_char:
.(
    and #%01111111  ; Avoid hitting code.
    pha
    jsr get_char_addr
    lda #0          ; Clear the new char.
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
    and #framechars/2+framechars/4
    cmp #framechars/2+framechars/4
    beq fake_addr
    txa
    and #sprbufmask
    cmp sprbank
    beq get_char_addrx
l2: jsr alloc_char
    iny
    sta (scr),y
    lda curcol
    sta (col),y
    rts

fake_addr:
    lda #0
    sta d+1
    rts
.)

get_char_addrx:
    txa

    ; Get char address.
get_char_addr:
    sta tmp
    asl
    asl
    asl
    sta d
    lda tmp
    lsr
    lsr
    lsr
    lsr
    lsr
    ora #>chars
    sta d+1
    rts

; Remove char if it's not in the current bank.
clear_char:
.(
    jsr scraddr
    ldy #0
    lda (scr),y
    and #framechars/2+framechars/4
    cmp #framechars/2+framechars/4
    beq e1
    lda (scr),y
    beq e1
    and #sprbufmask
    cmp sprbank
    beq e1
    tya
    sta (scr),y
e1: rts
.)
