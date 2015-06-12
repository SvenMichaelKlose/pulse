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

    ; Initialize trailing foreground chars.
    lda #<first_trailing_char
    sta d
    lda #>first_trailing_char
    sta @(++ d)
    lda #>background
    sta @(++ s)
    lda #<background                                                            
    ldy #@(-- (* 8 num_trailing_foreground_chars))
    jsr blit_copy

    ; Copy score digits from ROM charset.
    ldx #@(* 10 8)
l:  lda @(+ charset_locase (* 8 #x30)),x
    sta @(+ charset (* 8 score_char0)),x
    lda #cyan
    sta colors,x
    dex
    bpl -l

    ; Plot ship next to number of lifes.
    ldx #@(+ score_char0 10)
    stx lifes_on_screen

    ; Make number of lifes yellow.
    lda #yellow
    sta @(+ (- (++ lifes_on_screen) screen) colors)

    ; Initialize foreground scroller.
    lda #@(-- screen_height)
    sta level_old_y
    ldy #5
    jsr add_tile
    lda #3
    sta level_delay
    sta lifes

    ; Fill sprite slots with stars.
    ldx #@(- num_sprites 2)
l:  jsr remove_sprite
    dex
    bpl -l

    ; Set coin-up vector.
if @*virtual?*
    lda #<extra_coin
    sta $a000
    lda #>extra_coin
    sta $a001
end

; Re-entry point after lost life.
restart:
    ldx #$ff
    txs
    lda #150
    sta is_invincible
    inx
    stx is_firing
    stx weapon

    ; Make player sprite.
    ldx #@(-- num_sprites)
    ldy #@(- player_init sprite_inits)
    jsr replace_sprite
