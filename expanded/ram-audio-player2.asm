timer2 = @(/ (cpu-cycles *tv*) *ram-audio-rate2*)

sample_start2:  0 0
sample_end2:    0 0
bitpair: 6

play_audio_sample2:
    pha
    txa
    pha
    lda #>timer2
    sta $9115
mod_sample_ptr2:
    lda $1234
    ldx bitpair
l:  beq +n
    lsr
    dex
    jmp -l
    
n:  asl
    asl
    and #15
stop:
    sta $900e

    dec bitpair
    dec bitpair
    bpl +n
    lda #6
    sta bitpair

    inc @(+ 1 mod_sample_ptr2)
    bne +n
    inc @(+ 2 mod_sample_ptr2)
n:

    lda @(+ 1 mod_sample_ptr2)
    cmp sample_end2
    bne +n
    lda @(+ 2 mod_sample_ptr2)
    cmp @(++ sample_end2)
    bne +n

    lda sample_start2
    sta @(+ 1 mod_sample_ptr2)
    lda @(++ sample_start2)
    sta @(+ 2 mod_sample_ptr2)

n:  pla
    tax
    pla
    rti

stop_player2:
    lda #$7f        ; Disable NMI timer and interrupt.
    sta $911b
    lda #$7f
    sta $911e
    rts

start_player2:
    lda sample_start2
    sta @(+ 1 mod_sample_ptr2)
    lda @(++ sample_start2)
    sta @(+ 2 mod_sample_ptr2)

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

    lda #6
    sta bitpair

    lda #<timer2
    sta $9114
    lda #>timer2
    sta $9115

    ; Set IRQ vector.
    lda #<play_audio_sample2
    sta $318
    lda #>play_audio_sample2
    sta $319

    ; Enable NMI timer and interrupt.
    lda #$40
    sta $911b
    lda #$c0
    sta $911e

    ; Let the IRQ handler do everthing.
    cli
    rts
