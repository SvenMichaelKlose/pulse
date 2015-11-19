loaded_splash:
    org @*splash-start*
relocated_splash:

splash:
    ; Restore areas that have been destroyed by the loader.
    ldx #tape_leader_countdown
l:  lda saved_zeropage,x
    sta $0000,x
    lda saved_stack,x
    sta @(- #x200 tape_leader_countdown),x
    dex
    bpl -l

    ldy #4
p:  ldx #0
l:  lda $1000,x
    sta tmp
m:  $bd $00 $00 ;lda $0000,x
n:  sta $1000,x
    lda tmp
o:  $9d $00 $00 ;sta $0000,x
    inx
    bne -l
    inc @(+ -l 2)
    inc @(+ -m 2)
    inc @(+ -n 2)
    inc @(+ -o 2)
    dey
    bne -p

    lda #$09        ; Black screen, white border.
    sta $900f
    lda #148        ; Unblank screen. 20 columns.
    sta $9002
