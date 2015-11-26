fx = sm
do_play_fx = tmp2

title_screen:
    ldx #$ff
    txs

    lda #white
    sta curcol

    jsr game_over_screen
    jsr init_fx_player

l:  lda #0
    sta scrx
    lda #4
    sta scry
    lda #<txt_game
    sta s
    lda #>txt_game
    sta @(++ s)
    ldx #<fx_write_text
    lda #>fx_write_text
    ldy #1
    jsr show_fx

    ldx #100
    jsr fx_wait
    jsr fx_clear

    jmp -l

fx_write_text:
    dec tmp
    lda tmp
    and #%00000001
    bne +c
    jsr strchrout
    bne +c
    dec do_play_fx
c:  jmp cont_fx

fx_clear:
    ldx #<fx_clear2
    lda #>fx_clear2
    ldy #50
    jmp show_fx

fx_clear2:
    dec do_play_fx
    ldx do_play_fx
    lda #32
    sta @(+ screen 66),x
    sta @(+ screen 66 50),x
    sta @(+ screen 66 100),x
    sta @(+ screen 66 150),x
    sta @(+ screen 66 200),x
    sta @(+ screen 66 250),x
    sta @(+ screen 66 300),x
    sta @(+ screen 66 350),x
    sta @(+ screen 66 400),x
    jmp +cont_fx

fx_wait:
    ldx #<fx_wait2
    lda #>fx_wait2
    jmp show_fx

fx_wait2:
    dec do_play_fx
    jmp cont_fx


;;;;;;;;;;;;;;;;;
;;; FX PLAYER ;;;
;;;;;;;;;;;;;;;;;

init_fx_player:
    jsr hide_screen
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
    rts

show_fx:
    stx fx
    sta @(++ fx)
    sty do_play_fx

l:  lsr $9004
    bne -l

    lda @(+ #xede4 1)
    sta $9001
    lda @(+ #xede4 3)
    sta $9003
    lda #%11111100          ; Our charset.
    sta $9005

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    and #joy_fire
    beq +get_ready

    lda #@(? (eq *tv* :pal) 52 37)
m:  cmp $9004
    bne -m

    lda #%11110010      ; Up/locase chars.
    sta $9005

    jmp (fx)

cont_fx:
    lda do_play_fx
    beq +done
    jmp -l
done:
    rts

;;;;;;;;;;;;;;;;;;;;;;;;
;;; GET READY SCREEN ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

get_ready:
    jsr hide_screen
    jsr set_text_mode
    jsr clear_screen

    ; Print game over text.
    lda #white
    sta curcol
    lda #6
    sta scrx
    lda #11
    sta scry
    lda #<txt_get_ready
    sta s
    lda #>txt_get_ready
    sta @(++ s)
    jsr strout

    jsr show_screen
    ldx #@(* 2 (? (eq *tv* :pal) 50 60))
    jsr wait

    jsr wait_for_screen_bottom
    lda #%11111100          ; Our charset.
    sta $9005
    lda #@(+ reverse blue)  ; Screen and border color.
    sta $900f
    jmp post_patch

;;;;;;;;;;;;;;;;;;;;;;;;
;;; GAME OVER SCREEN ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

game_over_screen:
    jsr hide_screen
    jsr set_text_mode
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

    jsr show_screen
    ldx #@(* 3 (? (eq *tv* :pal) 50 60))
    jmp wait

;;;;;;;;;;;;;;
;;; SCREEN ;;;
;;;;;;;;;;;;;;

hide_screen:
    jsr wait_for_screen_bottom
    lda #0
    sta $9003
    rts

show_screen:
    jsr wait_for_screen_bottom
    lda @(+ #xede4 3)
    sta $9003
    rts

set_text_mode:
    lda #reverse        ; Screen and border color.
    sta $900f
    lda #%11110010      ; Up/locase chars.
    sta $9005
    rts

wait_for_screen_bottom:
    ; Avoid screen trash
    lda #@(? (eq *tv* :pal) 150 120)
l:  cmp $9004
    bne -l
    rts

clear_screen:
    ldx #253
l:  lda #32                                                                                            
    sta @(-- screen),x
    sta @(+ screen 252),x
    lda #0
    sta @(-- colors),x
    sta @(+ colors 252),x
    dex
    bne -l
    rts

wait:
l:  lsr $9004
    bne -l
m:  lsr $9004
    beq -m
    dex
    bne -l
    rts

strout:
    jsr strchrout
    bne strout
    rts

strchrout:
    ldy #0
    lda (s),y
    beq +done
    jsr chrout
    jsr inc_s
    lda #1
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
    lda curcol
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

;;;;;;;;;;;;;;;;
;;; POINTERS ;;;
;;;;;;;;;;;;;;;;

inc_s:
    inc s
    bne +done
    inc @(++ s)
done:
    rts

;;;;;;;;;;;;;
;;; TEXTS ;;;
;;;;;;;;;;;;;

txt_get_ready:
    @(ascii2petscii "GET READY!") 0

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
