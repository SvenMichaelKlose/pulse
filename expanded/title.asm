title_screen:
    ; Avoid screen trash
    lda #150
l:  cmp $9004
    bne -l

    ; Clear screen.
    lda #reverse    ; Screen and border color.
    sta $900f
    lda #@(* red 16)    ; Auxiliary color.
    sta $900e
    lda #%11110010      ; Up/locase chars.
    sta $9005
    ldy #white
    jsr clear_screen

    ; Print game over text.
    lda #7
    sta scrx
    lda #11
    sta scry
    lda #<txt_game_over
    sta s
    lda #>txt_game_over
    sta @(++ s)
    jsr strout

    ldx #@(* 3 (? (eq *tv* :pal) 50 60))
    jsr wait

    ldy #white
    jsr clear_screen

    ; Copy title chars.
    ldx #0
l:  lda gfx_title_chars,x
    sta @(+ #x1000 8),x
    dex
    bne -l

    ; Clear char 32.
    ldx #7
    lda #0
l:  sta @(+ #x1000 (* 32 8)),x
    dex
    bpl -l

    ; Copy title screen.
    ldx #13
l:  lda gfx_title_screen,x
    sta @(+ screen 4),x
    lda @(+ gfx_title_screen 14),x
    sta @(+ screen 4 22),x
    lda @(+ gfx_title_screen 28),x
    sta @(+ screen 4 44),x
    dex
    bpl -l

    ; Set title color.
    ldx #66
    lda #@(+ multicolor cyan)
l:  sta colors,x
    dex
    bpl -l

    lda #0
    sta scrx
    lda #4
    sta scry
    lda #<txt_game
    sta s
    lda #>txt_game
    sta @(++ s)

retrace:
l:  lda $9004
    bne -l

    lda #reverse    ; Screen and border color.
    sta $900f
    lda #%11111100          ; Our charset.
    sta $9005

    dec tmp
    lda tmp
    and #%00000001
    bne +l
    jsr strchrout

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    and #joy_fire
    beq +done

l:  lda $9004
    cmp #52
    bne -l

    lda #@(* red 16)    ; Auxiliary color.
    sta $900e
    lda #%11110010      ; Up/locase chars.
    sta $9005

    jmp retrace

done:
    lda #@(+ reverse blue)  ; Screen and border color.
    sta $900f
    jmp post_patch

clear_screen:
    ldx #253
l:  lda #32                                                                                            
    sta @(-- screen),x
    sta @(+ screen 252),x
    tya
    sta @(-- colors),x
    sta @(+ colors 252),x
    dex
    bne -l
    rts

wait:
l:  lda $9004
    bne -l
n:  lda $9004
    beq -n
    dex
    bne -l
    rts

strout:
    jsr strchrout
    bne strout
    rts

strchrout:
l:  ldy #0
    lda (s),y
    beq +done
    jsr chrout
    inc s
    bne +done
    inc @(++ s)
done:
    rts
    
chrout:
    cmp #255
    bne +n
    lda #0
    sta scrx
    inc scry
    rts
n:  pha
    jsr scrcoladdr
    pla
    sta (scr),y
    lda #white
    sta (col),y
    inc scrx
    rts

scrcoladdr:
    ldy scry
    lda $edfd,y
    sta scr
    sta col
    cpy #12
    lda #@(half (high screen))
    rol
    sta @(++ scr)
    and #1
    ora #@(high colors)
    sta @(++ col)
    ldy scrx
    rts

txt_game_over:
    @(ascii2petscii "GAME OVER") 0

txt_game:
    @(ascii2petscii "         GAME") 255 255

    @(ascii2petscii " Code, gfx and sound:") 255 255
    @(ascii2petscii "        pixel") 255
    @(ascii2petscii " (Sven Michael Klose)") 255 255
;   @(ascii2petscii "                      ") 255 255 255 255

    @(ascii2petscii "    SPLASH SCREEN") 255 255

    @(ascii2petscii "      Graphics:") 255 255
    @(ascii2petscii "       darkatx") 255
    @(ascii2petscii "    (Bryan Henry)") 255 255

    @(ascii2petscii "        Music:") 255 255
    @(ascii2petscii "        boray") 255
    @(ascii2petscii "  (Anders Petersson)") 0
