s = $0000
d = $0002
c = $0004
realstart = $1100
reallen   = realend-realstart

main:
    jsr clrscr
    lda #<start
    sta s
    lda #>start
    sta s+1
    lda #<realstart
    sta d
    lda #>realstart
    sta d+1
    lda #<reallen
    sta c
    lda #>reallen
    sta c+1
    jsr rmemcpy
    jmp init

start:
rmemcpy:
* = $1100
memcpy:
    ldy #0
l1: lda (s),y
    sta (d),y
    lda c
    bne l2
    lda c+1
    beq e1
    dec c+1
l2: dec c
    inc s
    bne l3
    inc s+1
l3: inc d
    bne l1
    inc d+1
    jmp l1
e1: rts

init:
    ; Upcase/downcase chars
    lda #%11111100
    sta $9005
    ; Screen and border to black.
    lda #0
    sta $900f
    rts
