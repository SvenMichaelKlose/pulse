; Replace decorative sprite by new one.
;
; Y: descriptor of new sprite in sprite_inits
add_sprite:
.(
    stx tmp
    sty tmp2

    ldx #numsprites-1
l4: lda sprites_i,x
    and #decorative
    bne add_sprite_at_x
    dex
    bpl l4
.)

sprite_added:
    ldx tmp
    ldy tmp2
    rts

; Replace sprite by decorative background star.
;
; X: sprite index
remove_sprite:
    stx tmp
    sty tmp2

    ; Add background star.
    jsr random
    sta star_init       ; Set X position.
    jsr random
    and #%11111000
    sta star_init+1     ; Set Y position.
    jsr random
    and #3
    sta star_init+7     ; Set speed.
    ldy #star_init-sprite_inits

; Replace decorative sprite by new one.
;
; X: sprite index
; Y: descriptor of new sprite in sprite_inits
add_sprite_at_x:
.(
    lda #sprites_x      ; Copy descriptor to sprite table.
    sta selfmod+1
l3: lda sprite_inits,y
selfmod:
    sta sprites_x,x
    iny
    lda selfmod+1
    cmp #sprites_d
    beq sprite_added
    adc #numsprites
    sta selfmod+1
    jmp l3
.)

; Move sprite X up A pixels.
sprite_up:
    jsr neg

; Move sprite X down A pixels.
sprite_down:
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts

; Move sprite X left A pixels.
sprite_left:
    jsr neg

; Move sprite X right A pixels.
sprite_right:
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts

; Test if sprite is outside the screen.
; Return carry flag set when true.
test_sprite_out:
.(
    lda sprites_x,x
    clc
    adc #8
    cmp #23*8
    bcs c1
    lda sprites_y,x
    clc
    adc #8
    cmp #24*8
c1: rts
.)

; Find collision with other sprite.
;
; X: sprite index
;
; Returns:
; C: Clear when a hit was found.
; Y: sprite index
find_hit:
.(
    txa
    pha
    stx tmp
    ldy #numsprites-1

l1: cpy tmp             ; Skip same sprite.
    beq n1
    lda sprites_i,y     ; Skip decorative sprite.
    and #decorative
    bne n1

    lda sprites_x,x     ; Get X distance.
    sec
    sbc sprites_x,y
    jsr abs
    cmp #8
    bcs n1              ; To far off horizontally...

    ; Vertically narrow down collision box of horizontal laser.
    lda #8
    sta collision_y_distance
    lda sprites_i,y
    cmp #deadly+2
    bne not_a_hoizontal_laser
    dec collision_y_distance
    dec collision_y_distance

not_a_hoizontal_laser:
    lda sprites_y,x     ; Get Y distance.
    sec
    sbc sprites_y,y
    jsr abs
    cmp collision_y_distance
    bcc c1              ; Got one!

n1: dey
    bpl l1
    sec

c1: pla
    tax
    rts
.)

; Draw all sprites.
draw_sprites:
.(
    ; Draw decorative sprites.
    ldx #numsprites-1
l2: lda sprites_i,x
    and #decorative
    beq n3
    jsr draw_sprite
n3: dex
    bpl l2

    ; Draw other sprites.
    ldx #numsprites-1
l1: lda sprites_i,x
    and #decorative
    bne n1

    sta foreground_collision

    jsr draw_sprite

    ; Save foreground collision.
    lda sprites_i,x
    and #%01111111
    ldy foreground_collision
    beq n2
    ora #128
n2: sta sprites_i,x

n1: dex
    bpl l1
.)

; Remove remaining chars of sprites in old frame.
clean_screen:
.(
    ldx #numsprites-1
l1: ; Remove old chars.
    lda sprites_ox,x
    sta scrx                ; (upper left)
    lda sprites_oy,x
    sta scry
    jsr scraddr_clear_char
    inc scrx                ; (upper right)
    jsr clear_char
    dec scrx                ; (bottom left)
    inc scry
    jsr scraddr_clear_char
    inc scrx                ; (bottom right)
    jsr clear_char

    ; Save current position as old one.
    jsr xpixel_to_char
    sta sprites_ox,x
    lda sprites_y,x
    jsr pixel_to_char
    sta sprites_oy,x

n1: dex
    bpl l1
    rts
.)

xpixel_to_char:
    lda sprites_x,x
pixel_to_char:
.(
    cmp #28*8
    bcs n
    lsr
    lsr
    lsr
    rts
n:  lda #$ff
    rts
.)

; Draw a single sprite.
draw_sprite:
.(
    txa
    pha
    lda #>sprite_gfx
    sta s+1
    lda sprites_l,x
    sta s
    sta sprite_data_top

    lda sprites_c,x
    sta curcol

    ; Calculate text position.
    jsr xpixel_to_char
    sta scrx
    lda sprites_y,x
    jsr pixel_to_char
    sta scry

    ; Configure the blitter.
    lda sprites_x,x
    and #%111
    tay
    sta blit_left_addr+1
    lda negate7,y
    sta blit_right_addr+1

    lda sprites_y,x
    and #%111
    sta sprite_shift_y
    tay
    lda negate7,y
    sta sprite_height_top

    ; Draw upper left.
    jsr scrcoladdr
    jsr prepare_upper_blit
    jsr blit_right

    beq n2

    ; Draw upper right.
    inc scrx
    jsr prepare_upper_blit
    jsr blit_left
    dec scrx

n2: lda sprite_shift_y
    beq n1

    ; Draw lower left.
    inc scry
    jsr scraddr_get_char
    lda s
    sec
    adc sprite_height_top
    sta sprite_data_bottom
    ldy sprite_shift_y
    dey
    jsr blit_right

    beq n1

    ; Draw lower right.
    inc scrx
    jsr get_char
    lda sprite_data_bottom
    ldy sprite_shift_y
    dey
    jsr blit_left

n1: pla
    tax
    rts
.)

prepare_upper_blit:
    jsr get_char
    lda d
    clc
    adc sprite_shift_y
    sta d
    lda sprite_data_top
    ldy sprite_height_top
    rts
