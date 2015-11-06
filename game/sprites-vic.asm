draw_sprites:
    ; Draw decorative sprites.
    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    bpl +n
draw_sprite_caller_1:
    jsr draw_sprite
n:  dex
    bpl -l

    ; Draw other sprites.
    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    bmi +n

    lda #0
    sta foreground_collision
draw_sprite_caller_2:
    jsr draw_sprite
    lda sprites_i,x
    and #@(bit-xor 255 fg_collision)
    ora foreground_collision
    sta sprites_i,x

n:  dex
    bpl -l

    ; Remove remaining chars of sprites in old frame.
clean_sprites:
    ldx #@(-- num_sprites)
l:  ; Remove old chars.
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

    dex
    bpl -l
    rts

xpixel_to_char:
    lda sprites_x,x
pixel_to_char:
    cmp #$f8
    bcs +l      ; Keep sprite from popping out on the left.
    lsr
    lsr
    lsr
    rts
l:  lda #$ff
    rts

; Draw a single sprite.
draw_sprite:
    stx draw_sprite_x

    lda #>sprite_gfx
    sta @(++ s)
    lda sprites_l,x
    sta s
    sta sprite_data_top

    lda sprites_c,x
    sta curcol

    ; Calculate text position.
    jsr xpixel_to_char
    sta scrx
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta scry

    ; Configure the blitter.
    lda sprites_x,x
    and #%111
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

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

    beq +n

    ; Draw upper right.
    inc scrx
    jsr prepare_upper_blit
    jsr blit_left
    dec scrx

n:  lda sprite_shift_y
    beq +n

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

    beq +n

    ; Draw lower right.
    inc scrx
    jsr get_char
    lda sprite_data_bottom
    ldy sprite_shift_y
    dey
    jsr blit_left

n:  ldx draw_sprite_x
    rts

prepare_upper_blit:
    jsr get_char
    lda d
    clc
    adc sprite_shift_y
    sta d
    lda sprite_data_top
    ldy sprite_height_top
    rts
