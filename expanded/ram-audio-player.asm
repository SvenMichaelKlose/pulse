timer = @(/ (cpu-cycles *tv*) *ram-audio-rate*)

sample_start:   0 0
sample_end:     0 0
nibble: 0
do_play_loop:   0

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
    cmp sample_end
    bne +n
    lda @(+ 2 mod_sample_ptr)
    cmp @(+ 1 sample_end)
    bne +n

    lda do_play_loop
    beq no_loop
    jsr restart_audio
    jmp +n

no_loop:
    lda #$7f        ; Disable NMI timer and interrupt.
    sta $911b
    lda #$7f
    sta $911e

n:  pla
    tax
    pla
    rti

start_player:
    @(asm (fetch-file "shared/audio-boost.inc.asm"))

    lda #0
    sta nibble

    lda #<timer
    sta $9114
    lda #>timer
    sta $9115

    ; Set IRQ vector.
    lda #<play_audio_sample
    sta $318
    lda #>play_audio_sample
    sta $319

    ; Enable NMI timer and interrupt.
    lda #$40
    sta $911b
    lda #$c0
    sta $911e

    ; Let the IRQ handler do everthing.
    cli

restart_audio:
    lda sample_start
    sta @(+ 1 mod_sample_ptr)
    lda @(+ 1 sample_start)
    sta @(+ 2 mod_sample_ptr)
    rts
