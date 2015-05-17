mainloop:

; Something hit the terrain.
play_sound_foreground:
    lda sound_foreground
    beq +n
    lda #128
    sta vicreg_noise
    lda #@(+ (* red 16) 15)
    sta vicreg_auxcol_volume
    bne +n2
n:  sta no_stars
    lda sound_explosion
    bne +n2
    sta vicreg_noise
n2:

; "Ow!" sound if you die.
play_sound_dead:
    lda sound_dead
    beq play_sound_bonus
    ora #@(* red 16)
    sta vicreg_auxcol_volume
    ora #128
    jmp play_sound_bonus3

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
    jmp play_sound_laser

n:  lda sound_foreground
    bne +n2
    sta vicreg_noise
n2:

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

    lda lifes
    clc
    adc #score_char0
    sta @(++ lifes_on_screen)

; Initialize our "double buffering" for sprites.
init_frame:
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char

;#ifdef SHOW_CHARSET
;    ldx #@(-- num_chars)
;l2: txa
;    sta screen,x
;    lda #white
;    sta colors,x
;    dex
;    cpx #$ff
;    bne -l2
;#endif

; Call the functions that control sprite behaviour.
    ldx #@(-- num_sprites)
l1: lda sprites_fh,x
    beq +n1
    sta @(+ +m1 2)
    lda sprites_fl,x
    sta @(++ +m1)
    stx call_controllers_x
m1: jsr $1234
    ldx call_controllers_x
n1: dex
    bpl -l1

    lda framecounter_high
    cmp #4                  ; No terrain before frame 1024 (4 * 256).
    bcc +in_intro
    jsr draw_foreground     ; Scroll/redraw terrain.
    jsr process_level       ; Feed in terrain that enters the screen.
