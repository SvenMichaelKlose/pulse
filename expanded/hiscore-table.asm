hiscore_table:
    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #joy_fire
    bne no_fire

no_fire:
    ; Joystick up.
n:  tya
    and #joy_up
    bne +n

    ; Joystick down.
n:  tya
    and #joy_down
    bne +n

    ; Joystick left.
n:  tya
    and #joy_left
    bne +n

    ; Joystick right.
n:  lda #0          ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi +n

n:  rts

hiscores:
    @(apply #'nconc (maptimes [+ (maptimes [identity #\0] num_score_digits)
                                 (maptimes [identity #\ ] num_name_digits)]
                              num_hiscore_entries))
