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
    lda #<tmpt
    sta d
    lda #>tmpt
    sta d+1
    lda #>background
    sta s+1
    lda #<background                                                            
    ldy #15
    jsr blit_copy

lifes_addr = screen+1
score_addr = screen+4
hiscore_addr = screen+12+1

init_score_digits:
.(
    ldx #10*8
l:  lda charset_locase+$30*8,x
    sta charset+48*8,x
    dex
    bpl l

    ldx #7
l2: lda #48
    sta score_addr,x
    lda ship,x
    sta charset+58*8,x
    dex
    bpl l2

    ldx #58
    stx lifes_addr
    inx
    stx lifes_addr+1

    ldx #22
    lda #cyan
l3: sta colors,x
    dex
    bpl l3

    lda #yellow
    sta lifes_addr-screen+colors+1
.)

init_hiscore:
.(
    ldx #7
l2: lda hiscore,x
    sta hiscore_addr,x
    dex
    bpl l2
.)

init_level:
    lda #22
    sta level_old_y
    lda #0
    jsr add_brick
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
    lda lifes
    clc
    adc #48
    sta lifes_addr+1
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
    sta $900d
    lda #red*16+15
    sta $900e
    bne n2
n:  lda sound_explosion
    bne n2
    sta $900d
    sta $900c
n2:
.)

play_sound_dead:
.(
    lda sound_dead
    beq n
    ora #red*16
    sta $900e
    ora #128
    jmp play_sound_bonus3
n:
.)

play_sound_bonus:
    lda sound_bonus
    beq play_sound_bonus2
    ora #red*16
    sta $900e
    lda $9005
    ora #128
play_sound_bonus3:
    sta $900a
    sta $900b
    sta $900c
    jmp sound_done
play_sound_bonus2:
    sta $900a
    sta $900b
    sta $900c

play_sound_explosion:
.(
    lda sound_explosion
    beq n
    asl
    ora #red*16
    sta $900e
    lda #196
    sta $900d
    jmp play_sound_laser
n:
    lda sound_foreground
    bne n2
    sta $900d
n2:
.)

play_sound_laser:
    lda sound_laser
    beq play_sound_laser2
    asl
    asl
    ora #128+64
    sta $900b
sound_done_full_volume:
    lda #red*16+15
    sta $900e
    jmp sound_done
play_sound_laser2:

sound_done:
.(
    ldx #sound_end-sound_start
l:  lda sound_start,x
    beq n
    dec sound_start,x
n:  dex
    bpl l
.)

    jsr update_random
    jsr init_frame

#ifdef SHOW_CHARSET
.(
    ldx #numchars-1
l2: txa
    sta screen,x
    lda #white
    sta colors,x
    dex
    bpl l2
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
    lda random
    and #%00011111
    bne n
    jsr add_sniper
n:  jsr draw_sprites
    jsr add_scout
.)

    jmp mainloop
