current_low = 4
average = 5
tleft = 7

average_loop_cycles = @(half (+ 4 2 2 3))
sure_delay = 7
timer = @(- (* 8 audio_longest_pulse) average_loop_cycles sure_delay)

tape_audio_player:
    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ; Initialize VIA2 timer 1.
    ldx #0      ; one-shot mode
    stx $912b
a:  lda #0
    sta average
    sta @(++ average)
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
    sta $900f   ; (4) Something for the eye.

    ; Make sum of samples.
    txa
    clc
    adc average
    sta average
    bcc +n
    inc @(++ average)
    jmp -f

    ; Continue playing if less than 128 samples have been summed up.
n:  dec tleft
    bne -f

    ; Correct time of average pulse length doesn't match our desired value.
    lda @(++ average)   ; average / 256
    cmp #$29            ; 41… why?
    beq +j
    bcc +n
    dec current_low
    jmp +d
n:  inc current_low
d:  lda current_low
    sta $9124

    ; Divide average by 128 and restart summing up samples.
j:  lda @(++ average)
    asl
    sta average
    lda #0
    rol
    sta @(++ average)
    lda #128
    sta tleft
    jmp -f      ; (4)

;xlat: @(amplitude-conversions)
