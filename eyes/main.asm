screen_columns  = 22
screen_rows  = 23
xpos = 4

loaded_intro:

    org $1a00

intro_start:
    ; Clear zero page.
    ldx #0
    txa
l:  sta 0,x
    inx
    bne -l

    ; Load +3K RAM
    ldy #<loader_cfg_3k
    lda #>loader_cfg_3k
    jsr tape_loader_start

    lda #@(+ reverse black) ; Screen and border color.
    sta $900f
    jsr clear_screen

    inc $9000
    inc $9001
    inc $9001

l:  lda $9004
    bne -l
    lda #150            ; Unblank screen.
    sta $9002
    lda #%11110010      ; Up/locase chars.
    sta $9005

    lda #black
    sta curcol

    lda #4
    sta tmp
    lda #<txt_eyes
    sta s
    lda #>txt_eyes
    sta @(++ s)
    lda #9
    sta scry
l:  lda #@(+ xpos 4)
    sta scrx
    jsr strout
    jsr inc_s
    inc scry
    dec tmp
    bne -l

    lda #$ec
    sta @(+ screen xpos 0 (* 9 22))
    lda #$e2
    sta @(+ screen xpos 1 (* 9 22))
    sta @(+ screen xpos 2 (* 9 22))
    lda #$fb
    sta @(+ screen xpos 3 (* 9 22))
    lda #$61
    sta @(+ screen xpos 0 (* 10 22))
    sta @(+ screen xpos 0 (* 11 22))
    lda #$e1
    sta @(+ screen xpos 3 (* 10 22))
    sta @(+ screen xpos 3 (* 11 22))
    lda #$fc
    sta @(+ screen xpos 0 (* 12 22))
    lda #$62
    sta @(+ screen xpos 1 (* 12 22))
    sta @(+ screen xpos 2 (* 12 22))
    lda #$fe
    sta @(+ screen xpos 3 (* 12 22))

    jmp blink

tmp:    0

patch_3k_size = @(length (fetch-file (+ "obj/3k.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_3k:
    $00 $10
    <patch_3k_size @(++ >patch_3k_size)
    <init_3k >init_3k

txt_eyes:
    @(ascii2petscii "East") 0
    @(ascii2petscii "Yorkshire") 0
    @(ascii2petscii "Engineering") 0
    @(ascii2petscii "Software") 0

blink:
    lda #white
    sta @(+ colors xpos 4 (* 9 22))
    jsr laser
    lda #white
    sta @(+ colors xpos 4 (* 11 22))
    jsr laser
    lda #white
    sta @(+ colors xpos 4 (* 10 22))
    jsr laser
    lda #white
    sta @(+ colors xpos 4 (* 12 22))
    ldx #16
    jsr laser2

    lda #9
    jsr show_text
    lda #10
    jsr show_text
    lda #11
    jsr show_text
    lda #12
    jsr show_text
    ldx #@(delay-frames 16)
    jsr swait

    lda #15
    sta sound_bonus
l:  ldx #1
    jsr swait
    lda #white
    jsr set_rectangle_color
    ldx #1
    jsr swait
    lda #yellow
    jsr set_rectangle_color
    jmp -l

show_text:
    sta scry
    lda #@(+ xpos 4)
    sta scrx
    jsr scrcoladdr
    lda #white
l:  sta (col),y
    iny
    cpy #22
    bne -l
    inc sound_foreground
    ldx #@(delay-frames 6)
    jmp swait
    
laser:
    ldx #@(delay-frames 6)
laser2:
    lda #@(delay-frames 7)
    sta sound_laser
    jmp swait

set_rectangle_color:
    sta @(+ colors xpos 0 (* 9 22))
    sta @(+ colors xpos 1 (* 9 22))
    sta @(+ colors xpos 2 (* 9 22))
    sta @(+ colors xpos 3 (* 9 22))
    sta @(+ colors xpos 0 (* 10 22))
    sta @(+ colors xpos 0 (* 11 22))
    sta @(+ colors xpos 3 (* 10 22))
    sta @(+ colors xpos 3 (* 11 22))
    sta @(+ colors xpos 0 (* 12 22))
    sta @(+ colors xpos 1 (* 12 22))
    sta @(+ colors xpos 2 (* 12 22))
    sta @(+ colors xpos 3 (* 12 22))
    rts

swait:
    lsr $9004
    bne swait
m:  lsr $9004
    beq -m
    txa
    pha
    @(asm (fetch-file "game/sound.asm"))
    pla
    tax
    dex
    beq +done
    jmp swait
done:
    rts

init_3k:
    jsr clear_screen
    dec $9000
    jmp $1002
