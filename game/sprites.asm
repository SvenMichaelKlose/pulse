; Replace decorative sprite by new one.
;
; Y: descriptor of new sprite in sprite_inits
add_sprite:
    stx tmp
    sty tmp2

    ldy #@(-- numsprites)
l:  lda sprite_rr
    and #@(-- numsprites)
    tax
    inc sprite_rr
    lda sprites_i,x     ; Decorative?
    bmi replace_sprite2 ; Yes…
    dey
    bpl -l

sprite_added:
    ldx tmp
    ldy tmp2
    rts

replace_sprite2:
    ldy tmp2
    jmp replace_sprite

; Replace sprite by decorative background star.
;
; X: sprite index
remove_sprite:
    stx tmp
    sty tmp2

    ; Add background star.
    jsr random              ; Set X position.
    sta star_init
    jsr random              ; Set Y position.
    and #%11111000          ; (Align on rows to save chars,)
    sta @(++ star_init)
    jsr random              ; Set speed.
    and #3
    sta @(+ star_init 7)
    ldy #@(- star_init sprite_inits)

; Replace decorative sprite by new one.
;
; X: sprite index
; Y: descriptor of new sprite in sprite_inits
replace_sprite:
    lda #sprites_x      ; Copy descriptor to sprite table.
    sta @(++ +selfmod)
l:  lda sprite_inits,y
selfmod:
    sta sprites_x,x
    iny
    lda @(++ -selfmod)
    cmp #sprites_d
    beq sprite_added
    adc #numsprites
    sta @(++ -selfmod)
    jmp -l

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
    lda sprites_x,x
    clc
    adc #8
    cmp #@(* 23 8)
    bcs +out
    lda sprites_y,x
    clc
    adc #8
    cmp #@(* 24 8)
out:rts

; Find collision with other sprite.
;
; X: sprite index
;
; Returns:
; C: Clear when a hit was found.
; Y: Sprite index of other sprite.
find_hit:
    txa
    pha
    stx tmp
    ldy #@(-- numsprites)

l:  cpy tmp             ; Skip same sprite.
    beq +n
    lda sprites_i,y     ; Skip decorative sprite.
    bmi +n

    lda sprites_x,x     ; Get X distance.
    sec
    sbc sprites_x,y
    jsr abs
    cmp #8
    bcs +n             ; Too far off horizontally...

    ; Halven collision box of horizontal laser vertically.
    lda #8
    sta collision_y_distance
    lda sprites_l,y
    cmp #<laser
    bne not_a_hoizontal_laser
    lda #4
    sta collision_y_distance

not_a_hoizontal_laser:
    lda sprites_y,x     ; Get Y distance.
    sec
    sbc sprites_y,y
    jsr abs
    cmp collision_y_distance
    bcc +ok             ; Got one!

n:  dey
    bpl -l
    sec

ok: pla
    tax
    rts

; Draw all sprites.
draw_sprites:
    ; Draw decorative sprites.
    ldx #@(-- numsprites)
l:  lda sprites_i,x
    bpl +n
    jsr draw_sprite
n:  dex
    bpl -l

    ; Draw other sprites.
    ldx #@(-- numsprites)
l:  lda sprites_i,x
    bmi +n

    lda #0
    sta foreground_collision
    jsr draw_sprite

    ; Save foreground collision.
    lda foreground_collision
    ora sprites_i,x
    sta sprites_i,x

n:  dex
    bpl -l

    ; Remove remaining chars of sprites in old frame.
    ldx #@(-- numsprites)
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
    txa
    pha

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

n:  pla
    tax
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
