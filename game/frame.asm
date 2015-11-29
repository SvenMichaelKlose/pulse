    lda lifes
    clc
    adc #score_char0
    sta @(++ lifes_on_screen)

    ; Initialize our "double buffering" for sprites.
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char

    ; Check if game's over.
    lda death_timer
    beq +n
    dec death_timer
    bne +n
    lda lifes
    beq +g
    jmp restart

    ; Save hiscore to zeropage.
g:  ldx #7
l:  lda hiscore_on_screen,x
    sta hiscore,x
    dex
    bpl -l

if @*virtual?*
    $22 $01     ; Exit.
end
if @(not *virtual?*)
    jmp game_over
end

    ; Call the functions that control sprite behaviour.
n:  ldx #@(-- num_sprites)
l1: lda sprites_fh,x
    sta @(+ +m1 2)
    lda sprites_fl,x
    sta @(+ +m1 1)
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
