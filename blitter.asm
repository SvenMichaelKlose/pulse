; Blit bytes from s to d, shifting them to the right.
;
; Ins:
; Y: character height
; s: source address
; s: destination address
; blit_right_addr + 1: 7 - bits_to_shift
blit_right_whole_char:
    ldy #7
blit_right:
    sta s
_blit_right_loop:
    lda (s),y
    clc
blit_right_addr:
    bcc +s1
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
s1: ora (d),y
    sta (d),y
    dey
    bpl _blit_right_loop
    lda @(++ blit_left_addr)
    rts

; Blit bytes from s to d, shifting them to the left.
;
; Ins:
; Y: character height
; s: source address
; s: destination address
; blit_right_addr + 1: 7 - bits_to_shift
blit_left_whole_char:
    ldy #7
blit_left:
    sta s
_blit_left_loop:
    lda (s),y
    clc
blit_left_addr:
    bcc +s1
    asl
    asl
    asl
    asl
    asl
    asl
    asl
    asl
s1: ora (d),y
    sta (d),y
    dey
    bpl _blit_left_loop
    rts

blit_char:
    ldy #7
blit_copy:
    sta s
l1: lda (s),y
    sta (d),y
    dey
    bpl -l1
    rts

blit_clear_char:
    ldy #7
    lda #0
l1: sta (d),y
    dey
    bpl -l1
    rts
