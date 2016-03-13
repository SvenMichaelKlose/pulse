start_game:
    lda #150
    sta $9002       ; 22 columns
    lda #46         ; 23 rows
    sta $9003

    ldy #4
p:  ldx #0
    stx $9003
l:  $bd $00 $00 ;lda $0000,x
m:  sta $1000,x
    inx
    bne -l
    inc @(+ -l 2)
    inc @(+ -m 2)
    dey
    bne -p

    ; Return missing game part (chars 128-195) from color RAM.
    ldx #0
l:  lda $9500,x
    asl
    asl
    asl
    asl
    sta tmp
    lda $9400,x
    and #$0f
    ora tmp
    sta $1400,x
    dex
    bne -l

    jmp $1002

relocated_splash_end:
