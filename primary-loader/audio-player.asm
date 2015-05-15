current_low = 0
average = 1
tleft = 3

average_loop_cycles = @(half (+ 4 2 2 3))
sure_delay = 7
timer = @(- (* 8 audio_longest_pulse) average_loop_cycles sure_delay)

tape_audio_player:
    ldx #253
l:  lda #white
    sta @(-- colors),x
    sta @(+ colors 252),x
    dex
    bne -l

    lda #8
    sta $900f
    lda #46
    sta vicreg_rasterlo_rows_charsize

    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ; Initialize VIA2 timer 1.
    lda #0
    sta $912b   ; one-shot mode
    lda #<timer
    sta current_low
    ldy #>timer

    ; Play.
f:  lda $9121   ; (4) Reset the VIA2 CA1 status bit.
l:  lda $912d   ; (4) Read the VIA2 CA1 status bit.
    lsr         ; (2) Shift to test bit 2.
    lsr         ; (2)
    bcc -l      ; (2/3) Nothing happened yet. Try again…

    lda $9124   ; (4) Read the timer's low byte which is your sample.
    sty $9125   ; (4) Write high byte to restart the timer.
    tax
    lsr         ; (2) Reduce sample from 7 to 4 bits.
    lsr         ; (2)
    lsr         ; (2)
    sta $900e   ; (4) Play it!

    ; Make sum of samples.
    txa
    clc
    adc average
    sta average
    bcc +n
    inc @(++ average)
    bne -f

n:  dec tleft
    bne -f

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #joy_fire
    bne +s

    ldx #$f6
    txs
    lda #0
    sta $911c
    tax
    tay
    cli
    jmp $100d

    ; Correct time if average pulse length doesn't match our desired value.
s:  lda @(++ average)   ; average / 256
    tax
    cmp #41 ;@(- 64 average_loop_cycles sure_delay 5)
    beq +j              ; It's already what we want.
    bcc +n
    dec current_low
    bne +d
n:  inc current_low
d:  lda current_low
    sta $9124

    ; Divide average by 128 and restart summing up samples.
j:  txa
    asl
    sta average
    lda #0
    rol
    sta @(++ average)
    lda #128
    sta tleft
    bne -f      ; (4)
