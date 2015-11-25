game_over:
if @*tape-release?*
patch_caller:
    ; Test if patch is set for unexpanded machines.
    lda @(++ model_patch)
    beq +n
    jmp (model_patch)
n:
post_patch:
end

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
    lda #$ff                        ; Set grenade char.
    sta @(+ charset (* 64 8))
n:  cpx #@(++ (* 10 8))
    bcs +n
    lda @(-- (+ charset_locase (* 8 #x30))),x ; Copy score digits from ROM charset.
    sta @(-- (+ charset (* 8 score_char0))),x
    lda #cyan                       ; Set (hi)score counter color.
    sta colors,x
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

    ; Plot ship next to number of lifes.
    lda #@(+ score_char0 10)
    sta lifes_on_screen

    ; Make number of lifes yellow.
    lda #yellow
    sta @(+ (- (++ lifes_on_screen) screen) colors)

    ; Initialize foreground scroller.
    lda #@(-- screen_rows)
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

; Re-entry point after lost life.
restart:
    ldx #$ff
    txs
    lda #150
    sta is_invincible
    inx
    stx is_firing
    stx weapon

    jsr clean_sprites

    ; Make player sprite.
    ldx #@(-- num_sprites)
    ldy #@(- player_init sprite_inits)
    jsr replace_sprite
