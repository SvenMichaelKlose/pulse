restart:
    jsr clear_screen

;.(
;    ldx #numchars-1
;l1: txa
;    sta screen+17*22,x
;    dex
;    bpl l1
;.)

.(
    ldx #numsprites-1
l1: lda #0
    sta sprites_h,x
    lda #$ff
    sta sprites_ox,x
    dex
    bpl l1
.)

    ldy #player_init-sprite_inits
    jsr add_sprite
#ifdef STATIC
    ldy #player_init-sprite_inits
    lda player_init
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    adc #18
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    lda player_init
    adc #17
    sta player_init
    jsr add_sprite
    ldy #player_init-sprite_inits
    jsr add_sprite
    ldy #laser_init-sprite_inits
    jsr add_sprite
    ldy #bullet_init-sprite_inits
    jsr add_sprite
#endif

mainloop:
.(
#ifndef STATIC
    lda framecounter
    and #%111
    bne l1
    lda random
    and #127
    sta bullet_init+1
    lda random
    and #3
    ora #8
    sta bullet_init+3
    ldy #bullet_init-sprite_inits
    jsr add_sprite
l1:
#endif
    jsr frame
    jmp mainloop
.)

add_sprite:
.(
    txa
    pha
    ldx #15
l1: lda sprites_h,x
    bne l2
    lda sprite_inits,y
    sta sprites_x,x
    iny
    lda sprite_inits,y
    sta sprites_y,x
    iny
    lda sprite_inits,y
    sta sprites_i,x
    iny
    lda sprite_inits,y
    sta sprites_c,x
    iny
    lda sprite_inits,y
    sta sprites_l,x
    iny
    lda sprite_inits,y
    sta sprites_h,x
    iny
    lda sprite_inits,y
    sta sprites_fl,x
    iny
    lda sprite_inits,y
    sta sprites_fh,x
    pla
    tax
    rts
l2: dex
    bpl l1
    pla
    tax
    rts
.)

remove_sprite:
    lda #0
    sta sprites_h,x
    rts

sprite_up:
.(
    lda sprites_y,x
    beq e1
    dec sprites_y,x
e1: rts
.)

sprite_down:
.(
    lda sprites_y,x
    cmp #21*8
    bcs e1
    inc sprites_y,x
e1: rts
.)

sprite_left:
.(
    lda sprites_x,x
    beq e1
    dec sprites_x,x
e1: rts
.)

sprite_right:
.(
    lda sprites_x,x
    cmp #21*8
    bcs e1
    inc sprites_x,x
e1: rts
.)

find_hit:
.(
    txa
    pha
    stx tmp
    ldy #numsprites-1
l1: cpy tmp
    beq n1
    lda sprites_h,y
    beq n1

    lda sprites_x,x     ; Get X distance.
    sec
    sbc #8
    sec
    sbc sprites_x,y
    bpl l2
    clc                 ; Make it positive.
    eor #$ff
    adc #1
l2: and #%11110000
    bne n1
    lda sprites_y,x
    clc
    adc #8
    sec
    sbc sprites_y,y
    bpl l3
    clc
    eor #$ff
    adc #1
l3: and #%11110000
    beq c1
n1: dey
    bpl l1
    pla
    tax
    clc
    rts
c1: pla
    tax
    stc
    rts
.)

sprite_inits:
player_init:
    .byte 02, 81, 0, cyan,     <ship, >ship, <player_fun, >player_fun
laser_init:
    .byte 18, 80, 1, white+8,  <laser, >laser, <laser_fun,  >laser_fun
laser_up_init:
    .byte 18, 80, 1, yellow,  <laser_up, >laser_up, <laser_up_fun,  >laser_up_fun
laser_down_init:
    .byte 18, 80, 1, yellow,  <laser_down, >laser_down, <laser_down_fun,  >laser_down_fun
bullet_init:
    .byte 21*8, 89, 2, yellow+8, <bullet, >bullet, <bullet_fun, >bullet_fun

; Sprite handlers
; X: Current sprite number.
sprite_funs:

laser_fun:
.(
    jsr find_hit
    bcc n1
    lda sprites_i,y
    cmp #2
    beq c1
n1: lda sprites_x,x
    clc
    adc #11
    cmp #21*8
    bcs r1
    sta sprites_x,x
    rts
c1: jsr remove_sprite
    tya
    tax
r1: jmp remove_sprite
.)

laser_up_fun:
.(
    jsr find_hit
    bcc n1
    lda sprites_i,y
    cmp #2
    beq c1
n1: lda sprites_x,x
    clc
    adc #8
    cmp #21*8
    bcs r1
    sta sprites_x,x
    lda sprites_y,x
    sec
    sbc #8
    bmi r1
    sta sprites_y,x
    rts
c1: jsr remove_sprite
    tya
    tax
r1: jmp remove_sprite
.)

laser_down_fun:
.(
    jsr find_hit
    bcc n1
    lda sprites_i,y
    cmp #2
    beq c1
n1: lda sprites_x,x
    clc
    adc #8
    cmp #21*8
    bcs r1
    sta sprites_x,x
    lda sprites_y,x
    clc
    adc #8
    cmp #21*8
    bcs r1
    sta sprites_y,x
    rts
c1: jsr remove_sprite
    tya
    tax
r1: jmp remove_sprite
.)


has_double_laser: .byte 0
has_autofire:     .byte 0

fired_last_time: .byte 0
player_fun:
.(
    jsr find_hit
    bcc c1
    lda sprites_i,y
    cmp #2
    bne c1
    jmp restart
c1: lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #%00100000
    bne n0
    lda has_autofire
    bne a1
    lda fired_last_time
    bne n1
a1: lda framecounter    ; Little ramdomness to give the laser some action.
    lsr
    lsr
    and #7
    adc sprites_x,x
    sta laser_init
    lda sprites_x,x
    sta laser_up_init
    sta laser_down_init
    lda sprites_y,x
    sta laser_init+1
    sta laser_up_init+1
    sta laser_down_init+1
    inc laser_init+1
    lda #1
    sta fired_last_time
    lda has_double_laser
    beq s1
    ldy #laser_up_init-sprite_inits
    jsr add_sprite
    ldy #laser_down_init-sprite_inits
    jsr add_sprite
s1: ldy #laser_init-sprite_inits
    jmp add_sprite
n0: lda #0
    sta fired_last_time
n1: tya
    and #%00000100
    bne n2
    jsr sprite_up
    jsr sprite_up
n2: tya
    and #%00001000
    bne n3
    jsr sprite_down
    jsr sprite_down
n3: tya
    and #%00010000
    bne n4
    jsr sprite_left
    jsr sprite_left
n4: lda #0              ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    and #%10000000
    bne n5
    jmp sprite_right
    jmp sprite_right
n5: rts
.)

bullet_fun:
.(
    jsr sprite_left
    jsr sprite_left
    lda sprites_x,x
    bne l1
    jsr remove_sprite
l1: rts
.)
