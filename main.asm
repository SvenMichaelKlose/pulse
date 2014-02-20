game_over:
.(
    lda #0
    tax
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

restart:
    lda #max_fire_interval
    sta fire_interval
    lda #150
    sta is_invincible
    lda #0
    sta is_firing
    sta has_double_laser

mainloop:
#ifdef TIMING
    lda #8+blue
    sta $900f
#endif
.(
wait_retrace:
l:  lda $9004
    bne l
.)

update_framecounter:
.(
    inc framecounter
    bne n
    inc framecounter_high
n:
.)

    jsr update_random

switch_frame:
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
    cmp #1
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
