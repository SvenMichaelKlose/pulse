game_over:
.(
    lda #0
    ldx #hiscore-1
l1: sta 0,x
    sta charset,x
    dex
    bne l1
.)

    jsr clear_screen

clear_sprites:
.(
    ldx #numsprites-1
l1: ldy #0
    sty sprites_fh,x
    dey
    sty sprites_ox,x
    dex
    bpl l1
.)

init_trailing_foreground_chars:
    lda #<first_trailing_char
    sta d
    lda #>first_trailing_char
    sta d+1
    lda #>background
    sta s+1
    lda #<background                                                            
    ldy #15
    jsr blit_copy

init_score_digits:
.(
    ldx #10*8
l:  lda charset_locase+$30*8,x
    sta charset+score_char0*8,x
    dex
    bpl l

    ldx #7
l2: lda #score_char0
    sta score_on_screen,x
    lda ship,x
    sta charset+(score_char0+10)*8,x
    dex
    bpl l2

    ldx #score_char0+10
    stx lifes_on_screen

    ldx #22
    lda #cyan
l3: sta colors,x
    dex
    bpl l3

    lda #yellow
    sta lifes_on_screen-screen+colors+1
.)

init_hiscore:
.(
    ldx #7
l2: lda hiscore,x
    sta hiscore_on_screen,x
    dex
    bpl l2
.)

init_level:
    lda #22
    sta level_old_y
    lda #0
    jsr add_tile
    lda #3
    sta level_delay

init_player:
    lda #3
    sta lifes
    ldy #player_init-sprite_inits
    jsr add_sprite

make_stars:
.(
    ldx #numsprites
l:  jsr add_star
    dex
    bne l
.)

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

play_sound_foreground:
.(
    lda sound_foreground
    beq n
    lda #128
    sta vicreg_noise
    lda #red*16+15
    sta vicreg_auxcol_volume
    bne n2
n:  lda sound_explosion
    bne n2
    sta vicreg_noise
    sta vicreg_soprano
n2:
.)

play_sound_dead:
.(
    lda sound_dead
    beq n
    ora #red*16
    sta vicreg_auxcol_volume
    ora #128
    jmp play_sound_bonus3

n:
.)

play_sound_bonus:
    lda sound_bonus
    beq play_sound_bonus2
    ora #red*16
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

play_sound_explosion:
.(
    lda sound_explosion
    beq n
    asl
    ora #red*16
    sta vicreg_auxcol_volume
    lda #196
    sta vicreg_noise
    jmp play_sound_laser

n:  lda sound_foreground
    bne n2
    sta vicreg_noise
n2:
.)

play_sound_laser:
    lda sound_laser
    beq decrement_sound_counters
    asl
    asl
    ora #128+64
    sta vicreg_alto
full_volume:
    lda #red*16+15
    sta vicreg_auxcol_volume

decrement_sound_counters:
.(
    ldx #sound_end-sound_start
l:  lda sound_start,x
    beq n
    dec sound_start,x
n:  dex
    bpl l
.)

    lda lifes
    clc
    adc #score_char0
    sta lifes_on_screen+1

init_frame:
.(
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char
.)

#ifdef SHOW_CHARSET
.(
    ldx #numchars-1
l2: txa
    sta screen,x
    lda #white
    sta colors,x
    dex
    cpx #$ff
    bne l2
.)
#endif

#ifndef STATIC
call_controllers:
.(
    ldx #numsprites-1
l1: lda sprites_fh,x
    beq n1
    sta m1+2
    lda sprites_fl,x
    sta m1+1
    txa
    pha
m1: jsr $1234
    pla
    tax
n1: dex
    bpl l1
.)
#endif

.(
    lda framecounter_high
    cmp #4
    bcc n
    jsr draw_foreground
    jsr process_level
    jsr random
    and #sniper_probability
    bne n
    jsr add_sniper
n:  jsr draw_sprites
    jsr add_scout
.)

increment_framecounter:
.(
    inc framecounter
    bne n
    inc framecounter_high
n:
.)

    jmp mainloop
