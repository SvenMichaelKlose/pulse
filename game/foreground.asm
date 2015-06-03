first_trailing_char  = @(+ charset (* 8 (+ foreground framemask)))
first_tile           = @(+ charset (* 8 (+ foreground framemask num_trailing_foreground_chars)))

test_on_foreground:
    ldy scrx
    lda (scr),y
    and #foreground
    cmp #foreground
    rts

add_tile:
    pha
    ldx free_tiles
    inx
    txa
    dex
    and #@(-- num_tiles)
    sta free_tiles
    lda #screen_width
    clc
    adc scrolled_chars
    sta screen_tiles_x,x
    lda level_old_y
    sta screen_tiles_y,x
    lda #0
    sta screen_tiles_n,x
    tya
    sta screen_tiles_i,x
    pla
done:
    rts

fetch_foreground_char:
    lda next_foreground_char
    inc next_foreground_char
    jmp fetch_char

draw_foreground:
    lda scrolled_bits
    dec scrolled_bits
    and #%111
    beq +n
    lda framecounter
    lsr
    bcs -done
    jmp rotate_tiles

no_more_tiles:
    jmp rotate_trailing_chars

n:  inc scrolled_chars
    lda #>foreground_gfx
    sta @(++ s)

    ; Reset character allocations.
    lda #0
    sta active_tiles
    ldx #@(- tiles_m tiles_l 1)
l:  sta tiles_c,x
    dex
    bpl -l
    lda #@(+ framemask foreground num_trailing_foreground_chars)
    sta next_foreground_char
    lda leftmost_tile
    and #@(-- num_tiles)
    sta counter

loop:
    lda counter
    and #@(-- num_tiles)
    cmp free_tiles
    beq no_more_tiles

    tax
    lda screen_tiles_n,x    ; Get height of tile.
    sta repetition
    lda screen_tiles_y,x    ; Get Y position.
    sta scry
    lda screen_tiles_x,x    ; Get X position.
    sec
    sbc scrolled_chars      ; Apply character-wise scrolling.
    sta scrx
    sta tmp3                ; Save X position for repetitions.
    lda screen_tiles_i,x
    tax
    lda tiles_c,x
    beq draw_chars

restart_plotting_chars:
    lda scrx
repeat_plotting_chars:
    cmp #$fd            ; Off-screen...
    beq remove_tile
    bcs draw_right
    cmp #screen_width
    bcs no_more_tiles  ; Off-screen...
    jsr scrcoladdr
    lda #@(+ yellow multicolor) ; Set left char and color.
    sta (col),y
    lda tiles_c,x
    sta (scr),y
draw_right:
    inc scrx
    lda scrx
    cmp #screen_width  ; Off-screen...
    bcs +n
    jsr scrcoladdr
    lda tiles_c,x      ; Plot regular right char.
    clc
    adc #1
    sta (scr),y
n:  inc scrx
    lda scrx
    cmp #screen_width  ; Off-screen...
    bcs +repeat
    jsr scrcoladdr
    lda tiles_r,x
    beq plot
    cmp #@(+ <background (* 8 num_trailing_foreground_chars))
    bcs +plot
    sec
    sbc #<background
    lsr
    lsr
    lsr
plot_background:
    ora #@(+ framemask foreground)
plot:
    sta (scr),y
repeat:
    dec repetition
    bmi +next_tile
    dec scry
    lda tmp3
    sta scrx
    jmp repeat_plotting_chars

remove_tile:
    inc leftmost_tile
next_tile:
    inc counter
    jmp -loop

draw_chars:
    jsr fetch_foreground_char
    sta tiles_c,x
    lda tiles_l,x
    beq +n
    jsr blit_char
    bmi +l ; jmp
n:  jsr blit_clear_char
l:  jsr fetch_foreground_char
    lda tiles_m,x
    jsr blit_char
    lda tiles_r,x
    ldy active_tiles
    sta tilelist_r,y
    inc active_tiles
    jmp restart_plotting_chars

rotate_tiles:
    ; Set pointer to left char.
    lda #<first_tile
    sta sl
    lda #>first_tile
    sta @(++ sl)
    sta @(++ sm)

    ldx #0
next_tile:
    cpx active_tiles
    beq rotate_trailing_chars

    ; Set pointer to middle char.
    lda sl
    clc
    adc #8
    sta sm

    ; Set pointer to right char.
    lda tilelist_r,x
    beq +n1
    cmp #@(+ <background (* 8 num_trailing_foreground_chars))
    bcs +n1
    sec
    sbc #<background
    lsr
    lsr
    lsr
    ora #@(+ framemask foreground)
n1: jsr get_char_addr
    sta @(++ sr)
    lda d
    sta sr

    ; Rotate.
    ldy #7
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
    bpl -l

    ; Step to next tile in charset.
    lda sl
    clc
    adc #16
    sta sl
    inx
    jmp -next_tile

rotate_trailing_chars:
    lda #<first_trailing_char
    sta sl
    lda #>first_trailing_char
    sta @(++ sl)
    ldy #@(-- (* 8 num_trailing_foreground_chars))
l:  lda (sl),y
    asl
    adc #0
    asl
    adc #0
    sta (sl),y
    dey
    bpl -l
    rts
