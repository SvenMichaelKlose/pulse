game_over:
    ; Zero out various areas.
    ldx #@(-- hiscore)
l:  lda #0
    sta 0,x                         ; Clear zero page.
    sta @(-- screen),x              ; Clear screen.
    sta @(- (+ screen hiscore) 2),x
    sta @(- (+ screen hiscore hiscore) 3),x
    cpx #9
    bcs +n
    sta @(-- charset),x             ; Clear first character.
    lda #score_char0                ; Set score digits to 0.
    sta @(-- score_on_screen),x
    lda @(-- ship),x                ; Copy ship to score charset.
    sta @(-- (+ charset (* 8 (+ score_char0 10)))),x
    lda @(-- hiscore),x             ; Copy hiscore to screen.
    sta @(-- hiscore_on_screen),x
    lda #$ff
    sta @(+ charset (* 64 8))
n:  dex
    bne -l

    jsr set_screws

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
    ldy #5
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
    sta weapon
