timer = @(/ (cpu-cycles *tv*) *ram-audio-rate*)

sample_start:   0 0
sample_end:     0 0
nibble: 0

play_audio_sample:
    pha
    txa
    pha
    lda #>timer
    sta $9115
mod_sample_ptr:
    lda $1234
    ldx nibble
    beq +n
    lsr
    lsr
    lsr
    lsr
n:  sta $900e

    lda nibble
    eor #1
    sta nibble
    bne +n

    inc @(+ 1 mod_sample_ptr)
    bne +n
    inc @(+ 2 mod_sample_ptr)
n:

    lda @(+ 1 mod_sample_ptr)
    cmp #<sample_end
    bne +n
    lda @(+ 2 mod_sample_ptr)
    cmp #>sample_end
    bne +n

    lda #$7f        ; Disable NMI timer and interrupt.
    sta $911b
    lda #$7f
    sta $911e

n:  pla
    tax
    pla
    rti

start_player:
    ; Boost digital audio.
    lda #$00
    sta $900e
    ldx #$7e
    stx $900c
    ldy #0
l:  dey
    bne -l
    lda #$fe
    stx $900c
    stx $900c
    sta $900c
    sta $900c
    stx $900c
    sta $900c

    lda #0
    sta nibble
    lda #$40        ; Enable NMI timer and interrupt.
    sta $911b
    lda #$c0
    sta $911e

    lda #<timer
    sta $9114
    lda #>timer
    sta $9115

    ; Set IRQ vector.
    lda #<play_audio_sample
    sta $318
    lda #>play_audio_sample
    sta $319

    ; Let the IRQ handler do everthing.
    cli
    rts
