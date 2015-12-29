start = $120c

    org $351

model_detection:
    lda #vic_unexpanded
    sta model

    ; Test on +3K.
    ldx #vic_3k
    ldy #$04
    jsr check_model

    ; Test on +8K.
    ldx #vic_8k
    ldy #$20
    jsr check_model

    ; Test on +16K.
    ldx #vic_16k
    ldy #$40
    jsr check_model

    ; Test on +24K.
    ldx #vic_24k
    ldy #$60
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
p:  lda $ff01,x
q:  sta $1201,x
    inx
    bne -p
    inc @(+ -p 2)
    inc @(+ -q 2)
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
