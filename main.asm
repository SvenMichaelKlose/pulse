;; Zero out various areas.
game_over:
    ldx #@(-- hiscore)
l1: lda #0
    sta 0,x                         ; Clear zero page.
    sta @(-- screen),x              ; Clear screen.
    sta @(- (+ screen hiscore) 2),x
    sta @(- (+ screen hiscore hiscore) 3),x
    cpx #9
    bcs +l3
    sta @(-- charset),x             ; Clear first character.
    lda #score_char0                ; Set score digits to 0.
    sta @(-- score_on_screen),x
    lda @(-- ship),x                ; Copy ship to score charset.
    sta @(-- (+ charset (* 8 (+ score_char0 10)))),x
    lda @(-- hiscore),x             ; Copy hiscore to screen.
    sta @(-- hiscore_on_screen),x
    lda #$ff
    sta @(+ charset (* 64 8))
l3: dex
    bne -l1

init_trailing_foreground_chars:
    lda #<first_trailing_char
    sta d
    lda #>first_trailing_char
    sta @(++ d)
    lda #>background
    sta @(++ s)
    lda #<background                                                            
    ldy #15
    jsr blit_copy

init_score_digits:
    ldx #@(* 10 8)
l:  lda @(+ charset_locase (* 8 #x30)),x
    sta @(+ charset (* 8 score_char0)),x
    lda #cyan
    sta colors,x
    dex
    bpl -l

    ldx #@(+ score_char0 10)
    stx lifes_on_screen

    lda #yellow
    sta @(+ (- (++ lifes_on_screen) screen) colors)

    lda #22
    sta level_old_y
    ldy #0
    jsr add_tile
    lda #3
    sta level_delay
    sta lifes
    ldx #@(-- numsprites)
    ldy #@(- player_init sprite_inits)
    jsr replace_sprite

make_stars:
    ldx #@(- numsprites 2)
l:  jsr remove_sprite
    dex
    bne -l

; Re-entry point after lost life.
restart:
    ldx #$ff
    txs
    lda #max_fire_interval
    sta fire_interval
    lda #150
    sta is_invincible
    lda #0
    sta is_firing
    sta has_double_laser
    sta has_autofire

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
    beq +n
    ora #@(* red 16)
    sta vicreg_auxcol_volume
    ora #128
    jmp play_sound_bonus3

n:

; Bonus "ping!".
play_sound_bonus:
    lda sound_bonus
    beq play_sound_bonus2
    ora #@(* red 16)
    sta vicreg_auxcol_volume
    lda $9005           ; Häh?
    ora #128
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
;    ldx #@(-- numchars)
;l2: txa
;    sta screen,x
;    lda #white
;    sta colors,x
;    dex
;    cpx #$ff
;    bne -l2
;#endif

; Call the functions that control sprite behaviour.
call_controllers:
    ldx #@(-- numsprites)
l1: lda sprites_fh,x
    beq +n1
    sta @(+ +m1 2)
    lda sprites_fl,x
    sta @(++ +m1)
    txa
    pha
m1: jsr $1234
    pla
    tax
n1: dex
    bpl -l1

    lda framecounter_high
    cmp #4                  ; No terrain before frame 1024 (4 * 256).
    bcc +n
    jsr draw_foreground     ; Scroll/redraw terrain.
    jsr process_level       ; Feed in terrain that enters the screen.

    ; Add a sniper on occasion.
    jsr random
    and #sniper_probability
    bne +n
    lda level_delay
    cmp #2              ; Avoid flickering snipers in right corners.
    bcc +n
    jsr add_sniper
n:
    jsr add_scout
    jsr draw_sprites

increment_framecounter:
    inc framecounter
    bne +n
    inc framecounter_high
n:

    jsr grenade
    jmp mainloop
