realstart   = $1000 + charsize
reallen     = realend-realstart
end         = start+reallen
rels     = end-1
reld     = realend-1

s           = $00
d           = $02
c           = $04

main:
    jsr clrscr
.(
    lda #<rels
    sta s
    lda #>rels
    sta s+1
    lda #<reld
    sta d
    lda #>reld
    sta d+1
    lda #<reallen
    sta c
    lda #>reallen
    sta c+1
    ldy #0
l1: lda c
    bne l2
    lda c+1
    beq e1
    dec c+1
l2: dec c
    lda (s),y
    sta (d),y
    lda s
    bne l3
    dec s+1
l3: dec s
    lda d
    bne l4
    dec d+1
l4: dec d
    jmp l1
e1:
.)

    cli
    lda #$7f
    sta $912e     ; disable and acknowledge interrupts
    sta $912d
    sta $911e     ; disable NMIs (Restore key)

.(
l1: lda $9004
    bne l1
.)

    ; Avoid showing garbage in char 0.
.(
    ldx #$0f
    lda #0
l1: sta chars,x
    dex
    bpl l1
.)

    lda #%11111100  ; Our charset.
    sta $9005
    lda #8+blue       ; Screen and border.
    sta $900f
    lda #red*16     ; Auxiliary color.
    sta $900e

    jmp realstart

start:
* = realstart
