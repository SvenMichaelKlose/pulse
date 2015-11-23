; Replace decorative sprite by new one.
;
; Round-robin search for a decorative sprite.
; This way decorative sprites last as long as possible.
;
; Y: descriptor of new sprite in sprite_inits
block
add_sprite:
    stx add_sprite_x
    sty add_sprite_y

    ldy #@(-- num_sprites)
l:  lda sprite_rr
    and #@(-- num_sprites)
    tax
    inc sprite_rr
    lda sprites_i,x     ; Decorative?
    bmi replace_sprite2 ; Yes…
    dey
    bpl -l

sprite_added:
    ldx add_sprite_x
    ldy add_sprite_y
    rts

replace_sprite2:
    ldy add_sprite_y
    jmp replace_sprite
end block

block
; Replace sprite by decorative background star.
;
; X: sprite index
remove_sprite:
    stx add_sprite_x
    sty add_sprite_y

remove_sprite_regs_already_saved:
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

; Replace sprite by another.
;
; X: sprite index
; Y: low address byte of descriptor of new sprite in sprite_inits
replace_sprite:
    lda #sprites_x          ; Copy descriptor to sprite table.
    sta @(++ +selfmod)
l:  lda sprite_inits,y
selfmod:
    sta sprites_x,x
    iny
    lda @(++ -selfmod)
    cmp #sprites_d
    beq sprite_added
    adc #num_sprites
    sta @(++ -selfmod)
    jmp -l
end block

block
; Move sprite X up A pixels.
sprite_up:
    jsr neg

; Move sprite X down A pixels.
sprite_down:
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts
end block

block
; Move sprite X left A pixels.
sprite_left:
    jsr neg

; Move sprite X right A pixels.
sprite_right:
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts
end block

; Test if sprite X is outside the screen.
; Return carry flag set when true.
block
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
end block

; Find collision with other sprite.
;
; X: sprite index
;
; Returns:
; C: Clear when a hit was found.
; Y: Sprite index of other sprite.
block
find_hit:
    stx tmp
    ldy #@(-- num_sprites)

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
    lda #2
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

ok: rts
end block
