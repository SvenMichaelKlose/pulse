first_trailing_char  = (foreground+framemask) * 8 + charset
second_trailing_char = (foreground+framemask+1) * 8 + charset
first_tile           = (foreground+framemask+2) * 8 + charset

test_on_foreground:
    ldy #0
    lda (scr),y
    and #foreground
    cmp #foreground
    rts

add_tile:
.(
    pha
    lda free_tiles
    tax
    clc
    adc #1
    and #numtiles-1
    sta free_tiles
    lda #22
    clc
    adc scrolled_chars
    sta screen_tiles_x,x
    lda level_old_y
    sta screen_tiles_y,x
    lda #0
    sta screen_tiles_n,x
    pla
    sta screen_tiles_i,x
    rts
.)

fetch_foreground_char:
    lda next_foreground_char
    inc next_foreground_char
    jmp fetch_char

draw_foreground:
.(
    lda scrolled_bits
    dec scrolled_bits
    and #%111
    beq n1
    lda framecounter
    and #1
    bne r
    jmp rotate_tiles

r:  rts

no_more_tiles:
    jmp rotate_trailing_chars:

n1: inc scrolled_chars

reset_chars:
    lda #0
    ldx #tiles_col-tiles_c-1
i1: sta tiles_c,x
    dex
    bpl i1
    sta active_tiles
    lda #framemask+foreground+2
    sta next_foreground_char
    lda leftmost_tile
    sta counter

loop:
    lda counter
    and #numtiles-1
    cmp free_tiles
    beq no_more_tiles
    tax
    lda screen_tiles_n,x
    sta repetition
    lda screen_tiles_y,x
    sta scry
    lda screen_tiles_x,x
    sec
    sbc scrolled_chars
    sta scrx
    sta tmp3                ; Save X for repetition.
    lda screen_tiles_i,x
    sta tmp2
    tax
    lda tiles_c,x
    beq draw_chars

restart_plotting_chars:
    lda scrx
repeat_plotting_chars:
    cmp #$fd            ; Off-screen...
    beq remove_tile
    bcs draw_right
    cmp #22
    bcs no_more_tiles  ; Off-screen...
    jsr scrcoladdr
    lda tiles_col,x    ; Set left char and color.
    sta (col),y
    lda tiles_c,x
    sta (scr),y
draw_right:
    inc scrx
    lda scrx
    cmp #22             ; Off-screen...
    bcs n2
    jsr scraddr
    lda tiles_c,x      ; Plot regular right char.
    clc
    adc #1
    sta (scr),y
n2: inc scrx
    lda scrx
    cmp #22             ; Off-screen...
    bcs repeat
    jsr scraddr
    lda tiles_r,x
    beq plot
    cmp #<background
    bne try_foreground
    lda #framemask+foreground
    bne plot
try_foreground:
    cmp #<bg_t
    bne repeat
    lda #framemask+foreground+1
plot:
    sta (scr),y
repeat:
    dec repetition
    lda repetition
    bmi next_tile
    dec scry
    lda tmp3
    sta scrx
    jmp repeat_plotting_chars

remove_tile:
    inc leftmost_tile
    lda leftmost_tile
    and #numtiles-1
    sta leftmost_tile
next_tile:
    inc counter
    jmp loop

draw_chars:
    jsr fetch_foreground_char
    sta tiles_c,x
    lda tiles_l,x
    beq n4
    jsr blit_char
    jmp n5
n4: jsr blit_clear_char
n5: jsr fetch_foreground_char
    lda tiles_m,x
    jsr blit_char
    lda tiles_r,x
    ldy active_tiles
    sta tilelist_r,y
    inc active_tiles
    ldx tmp2
    jmp restart_plotting_chars
.)

rotate_tiles:
.(
    lda #<first_tile
    sta sl
    lda #>first_tile
    sta sl+1

    ldx #0
l1: cpx active_tiles
    beq rotate_trailing_chars

    lda sl              ; Set pointer to middle char.
    clc
    adc #8
    sta sm
    lda sl+1
    clc
    adc #0
    sta sm+1

    lda tilelist_r,x   ; Set pointer to right char.
    beq n3
    cmp #<background
    bne n4
    lda #framemask+foreground
    jmp n3
n4: cmp #<bg_t
    bne n3
    lda #framemask+foreground+1
n3: jsr get_char_addr
    lda d
    sta sr
    lda d+1
    sta sr+1

    ldy #7              ; Rotate.
l:  lda (sr),y
    rol
    sta tmp
    lda (sm),y
    rol
    sta tmp2
    lda (sl),y
    rol
    sta tmp3
    lda tmp
    asl
    lda tmp2
    rol
    sta (sm),y
    lda tmp3
    rol
    sta (sl),y
    dey
    bpl l

    lda sl          ; Step to next tile in charset.
    clc
    adc #16
    sta sl
    lda sl+1
    clc
    adc #0
    sta sl+1
    inx
    jmp l1
.)

rotate_trailing_chars:
.(
    lda #<first_trailing_char
    sta sl
    lda #>first_trailing_char
    sta sl+1
    ldy #15
l:  lda (sl),y
    asl
    adc #0
    asl
    adc #0
    sta (sl),y
    dey
    bpl l
    rts
.)
