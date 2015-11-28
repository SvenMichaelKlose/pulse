; Reuse char already allocated by another sprite.
reuse_char:
    lda curcol
    ldy scrx
    sta (col),y
    txa

; Get address of character in charset.
get_char_addr:
    sta tmp
    asl
    asl
    asl
    sta d
    lda tmp
    lsr
    lsr
    lsr
    lsr
    lsr
    ora #>charset
    sta @(++ d)
    rts

; We've run out of chars. Reset allocation.
alloc_wrap:
    lda spriteframe
    ora #first_sprite_char
    sta no_stars    ; Draw stars black to avoid visible trash everywhere.
    bne fetch_char      ; (JMP)

alloc_char:
    lda next_sprite_char
    and #foreground
    cmp #foreground
    beq alloc_wrap      ; No chars left…
    lda next_sprite_char
    inc next_sprite_char

fetch_char:
    and #charsetmask
    pha
    jsr get_char_addr
    jsr blit_clear_char
    pla
    iny
    rts

test_position:
    lda scry
    cmp #screen_rows
    bcs +l
    lda scrx
    cmp #screen_columns
l:  tay
    rts

scraddr_get_char:
    jsr scrcoladdr

get_char:
    jsr test_position
    bcs cant_use_position
    lda (scr),y
    beq +l              ; Screen char isn't used, yet…
    tax
    and #foreground
    cmp #foreground
    beq on_foreground   ; Can't draw on foreground…
    txa
    and #framemask
    cmp spriteframe
    beq reuse_char      ; Already used by a sprite in current frame…
l:  jsr alloc_char
    ldy scrx
    sta (scr),y
    lda curcol
    sta (col),y
    rts

on_foreground:
    lda #fg_collision
    sta foreground_collision
cant_use_position:
    lda #$f0            ; Draw into ROM.
    sta @(++ d)
    rts

scraddr_clear_char:
    jsr scrcoladdr

clear_char:
    jsr test_position
    bcs +l
    lda (scr),y
    beq +l              ; Nothing to clear…
    and #foreground
    cmp #foreground
    beq +l              ; On scrolling foreground…
    lda (scr),y
    and #framemask
    cmp spriteframe
    beq +l              ; Current frame…
    lda #0
    sta (scr),y
l:  rts
