; Something hit the terrain.
play_sound_foreground:
    lda sound_foreground
    beq +n
    lda #128
    sta vicreg_noise
    lda #@(+ (* red 16) 15)
    sta vicreg_auxcol_volume
    bne play_sound_dead
n:  sta no_stars
    lda sound_explosion
    bne play_sound_dead
    sta vicreg_noise

; "Ow!" sound if you die.
play_sound_dead:
    lda sound_dead
    beq play_sound_bonus
    ora #@(* red 16)
    sta vicreg_auxcol_volume
    ora #128
    bne play_sound_bonus3   ; (JMP)

; Bonus "ping!".
play_sound_bonus:
    lda sound_bonus
    beq play_sound_bonus2
    ora #@(* red 16)
    sta vicreg_auxcol_volume
    lda #$fc
play_sound_bonus3:
    sta vicreg_bass
    sta vicreg_alto
    sta vicreg_soprano
    jmp decrement_sound_counters

play_sound_bonus2:
    sta vicreg_bass
    sta vicreg_alto
    sta vicreg_soprano

; An enemy is toast.
play_sound_explosion:
    lda sound_explosion
    beq +n
    asl
    ora #@(* red 16)
    sta vicreg_auxcol_volume
    lda #196
    sta vicreg_noise
    bne play_sound_laser    ; (JMP)

n:  lda sound_foreground
    bne play_sound_laser
    sta vicreg_noise

; Classic sound of a laser on its way.
play_sound_laser:
    lda sound_laser
    beq decrement_sound_counters
    asl
    asl
    ora #@(+ 128 64)
    sta vicreg_alto
full_volume:
    lda #@(+ (* red 16) 15))
    sta vicreg_auxcol_volume

decrement_sound_counters:
    ldx #@(- sound_end sound_start)
l:  lda sound_start,x
    beq +n
    dec sound_start,x
n:  dex
    bpl -l
