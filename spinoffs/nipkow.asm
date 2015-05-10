current_low = 0
average = 1
tleft = 3

average_loop_cycles = @(half (+ 4 2 2 3))
sure_delay = 7
timer = @(- (* 8 audio_longest_pulse) average_loop_cycles sure_delay)

tape_audio_player:
    sei         ; Disable interrupts.
    lda #$7f
    sta $911e
    sta $911d
    sta $912e
    sta $912d

    ; Set screen dimensions.
    lda #@(+ 128 16)
    sta $9002
    lda #@(* 16 2)
    sta $9003
    lda #$fd
    sta $9005
    lda #8
    sta $900f

    ldx #0
    lda #white
l:  sta colors,x
    sta @(+ 203 colors),x
    dex
    bne -l

    ldx #63
    ldy #64
l:  lda luminances,x
    sta $1400,x
    eor #$ff
    sta $1400,y
    iny
    dex
    bpl -l

    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ; Initialize VIA2 timer 1.
    lda #%00000000
    sta $912b
    lda #<timer
    sta current_low
    ldy #>timer

    ; Play sample.
play_audio:
    lda $9121   ; (4) Reset the VIA2 CA1 status bit.
l:  lda $912d   ; (4) Read the VIA2 CA1 status bit.
    lsr         ; (2) Shift to test bit 2.
    lsr         ; (2)
    bcc -l      ; (2/3) Nothing happened yet. Try again…

    lda $9124   ; (4) Read the timer's low byte which is your sample.
    ldx $9125   ; (4) Write high byte to restart the timer and acknowledge interrupt.
    sty $9125   ; (4) Write high byte to restart the timer and acknowledge interrupt.
    bmi framesync
    tax
    lsr         ; (2) Reduce sample from 7 to 4 bits.
    lsr         ; (2)
    lsr         ; (2)
    sta $900e   ; (4) Play it!

update_average:
    ; Make sum of samples.
    txa
    clc
    adc average
    sta average
    bcc +n
    inc @(++ average)
n:

    dec tleft
    bne play_video

    ; Correct time if average pulse length doesn't match our desired value.
s:  lda @(++ average)   ; average / 256
    tax
    cmp #$29            ; 41… why? Should be $40.
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

    ; Update pixel.
play_video:
    lda $9121   ; (4) Reset the VIA2 CA1 status bit.
l:  lda $912d   ; (4) Read the VIA2 CA1 status bit.
    lsr         ; (2) Shift to test bit 2.
    lsr         ; (2)
    bcc -l      ; (2/3) Nothing happened yet. Try again…

    lda $9124   ; (4) Read the timer's low byte which is your sample.
    ldx $9125   ; (4) Write high byte to restart the timer.
    sty $9125   ; (4) Write high byte to restart the timer.
    bmi framesync
    lsr         ; (2) Reduce sample from 7 to 4 bits.
    lsr         ; (2)
    lsr         ; (2)
p:  lda $1e00   ; Save as luminance char.
    inc @(+ -p 1) ; Step to next pixel.
    jmp play_audio ; Back to audio…

framesync:
    cmp #@(- (half (* 8 frame_sync_width)))
    bcs update_average
    cmp #@(- (* 8 frame_sync_width))
    bcc update_average
    lda #0
    sta @(+ -p 1)
    beq play_audio
