start = $120c
model = $1ffc

    org $351

model_detection:
    lda #0
    sta model

    ; Test on +3K.
    ldx #1
    ldy #$04
    jsr check_model

    ; Test on +8K.
    ldx #2
    ldy #$20
    jsr check_model

    ; Test on +16K.
    ldx #4
    ldy #$40
    jsr check_model

    ; Test on +24K.
    ldx #8
    ldy #$40
    jsr check_model

    ; Relocate for unexpanded.
    lda model
    bne +n
    lda #$10
    bne relocate

    ; No relocation for other than +3K.
n:  lsr
    bne +done

    lda #$04
relocate:
    sta @(+ +p 2)
    ldx #0
    ldy #2
p:  lda $1201,x
q:  sta $1201,x
    inx
    bne -p
    inc @(+ +p 2)
    inc @(+ +p 2)
    dey
    bne -p
done:
    jmp start

check_model:
    sty @(+ +p 2)
    sty @(+ +q 2)
    dey
    tya
p:  sta $1200
q:  cmp $1200
    bne +n
    txa
    ora model
    sta model
n:  rts
