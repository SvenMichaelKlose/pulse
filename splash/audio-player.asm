; Minus half of VIA CA1 status bit test loop cycles and instructions to reinit.
restart_delay = @(+ (half (+ 4 3 3)) 8)
timer = @(- (* 8 audio_longest_pulse) restart_delay)

tape_audio_player:
    ; Initialize VIA2 timer 1.
    lda #0
    sta $912b       ; one-shot mode
    lda #<timer
    sta current_low
    ldy #>timer

    ; Play.
f:  lda $9121       ; Reset the VIA2 CA1 status bit.
l:  lda $912d       ; Read the VIA2 CA1 status bit.
    and #2
    beq -l

    lda $9124       ; Read the timer's low byte which is your sample.
    sty $9125       ; Write high byte to restart the timer.

    tax
    bpl +n
    cmp #196
    bcc +s
    lda #0
    beq +n
s:  lda #127
n:  lsr             ; Reduce sample from 7 to 4 bits.
    lsr
    lsr
    ora #$40        ; Auxiliary colour.
    sta $900e       ; Play it!

    ; Make sum of samples.
    txa
    clc
    adc average
    sta average
    bcc +n
    inc @(++ average)

n:  dec tleft
    bne -f

    ; Correct time if average pulse length doesn't match our desired value.
    lda @(++ average)   ; average / 256
    cmp #$3f
    beq -f              ; It's already what we want.
    bcc +n
    dec current_low
    bne +d
n:  inc current_low
d:  lda current_low
    sta $9124

    lda #0
    sta average
    sta @(++ average)
    sta $9113
    lda $9111
    and #joy_fire
    bne -f
