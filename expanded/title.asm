fx = sm
do_play_fx = tmp2

title_screen:
    ldx #$ff
    txs

    lda #white
    sta curcol

    jsr game_over_screen
    jsr init_fx_player

l:  lda #<txt_game
    sta s
    lda #>txt_game
    sta @(++ s)
m:  lda #0
    sta scrx
    lda #9
    sta scry
    ldx #<fx_write_text
    lda #>fx_write_text
    ldy #1
    jsr show_fx
    ldx #@(? (eq *tv* :pal) 25 30)
    jsr fx_wait
    jsr fx_clear
    jsr inc_s
    ldy #0
    lda (s),y
    bne -m
    beq -l

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
    sta @(+ screen 68),x
    sta @(+ screen 68 50),x
    sta @(+ screen 68 100),x
    sta @(+ screen 68 150),x
    sta @(+ screen 68 200),x
    sta @(+ screen 68 250),x
    sta @(+ screen 68 300),x
    sta @(+ screen 68 350),x
;    sta @(+ screen 68 400),x
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

    lda #@(? (eq *tv* :pal) 52 37)
m:  cmp $9004
    bne -m

    lda #%11110010      ; Up/locase chars.
    sta $9005

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    and #joy_fire
    beq +get_ready

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
if @*have-ram-audio-player?*
    lda model
    and #vic_8k
    beq +n
    lda #<sample_get_ready
    sta @(+ 1 mod_sample_ptr)
    lda #>sample_get_ready
    sta @(+ 2 mod_sample_ptr)
    lda #<sample_get_ready_end
    sta @(+ 1 sample_end)
    lda #<sample_get_ready_end
    sta @(+ 2 sample_end)
    jsr start_player
n:
end

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
    lda #0
    sta $900a
    sta $900b
    sta $900c
    sta $900d
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


;;;;;;;;;;;;;
;;; TEXTS ;;;
;;;;;;;;;;;;;

txt_get_ready:
    @(ascii2petscii "GET READY!") 0

txt_game_over:
    @(ascii2petscii "GAME OVER") 0

txt_game:
    @(ascii2petscii "   First, do what's") 255 255
    @(ascii2petscii "       necessary.") 255 255
    @(ascii2petscii "    Then do what's") 255 255
    @(ascii2petscii "       possible.") 255 255
    @(ascii2petscii " And suddenly you're") 255 255
    @(ascii2petscii "doing the impossible.") 0

    @(ascii2petscii "        GAME:") 255 255
    @(ascii2petscii "        pixel") 255
    @(ascii2petscii " (Sven Michael Klose)") 255 255
    @(ascii2petscii "    www.hugbox.org") 0
;   @(ascii2petscii "                      ") 255 255 255 255

    255
    @(ascii2petscii "SPLASH SCREEN GRAPHICS") 255 255
    @(ascii2petscii "       darkatx") 255
    @(ascii2petscii "    (Bryan Henry)") 0

    @(ascii2petscii "  SPLASH SCREEN TUNE ") 255
    @(ascii2petscii "     ('No Syrup')") 255 255
    @(ascii2petscii "         boray") 255
    @(ascii2petscii "   (Anders Persson)") 255 255
    @(ascii2petscii "     www.boray.se") 0

    255
    255
    @(ascii2petscii "  HISCORE TABLE TUNE:") 255 255
    @(ascii2petscii "     Lukas Ramolla") 0

    255
    @(ascii2petscii "Love and respect go to") 255 255
    @(ascii2petscii "     the folks at") 255 255
    @(ascii2petscii "    VIC-20 Denial!") 0

    255 255
    @(ascii2petscii "   Hit fire to play!") 0 0

if @*have-ram-audio-player?*
sample_get_ready:
    @(fetch-file "obj/get_ready.pwm")
sample_get_ready_end:
end
