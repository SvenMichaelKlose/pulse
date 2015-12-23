    org $1000
    $02 $10

    ; Print `presents`.
    ldx #@(- txt_presents_end txt_presents 1)
l:  lda txt_presents,x
    sta @(+ screen (* 10 22) 7),x
    lda #white
    sta @(+ colors (* 10 22) 7),x
    dex
    bpl -l

    ; Fill +3K area.
    ldx #0
    ldy #$07
l:  lda loaded_patch3k,x
m:  sta $400,x
    dex
    bne -l
    inc @(+ 2 -l)
    inc @(+ 2 -m)
    dey
    bne -l

    ; Patch for unexpnded machines.
    lda #<post_patch
    sta model_patch
    lda #>post_patch
    sta @(++ model_patch)

    ; Check if there's only +3K RAM.
    lda model
    beq load_flight
    lsr
    bne load_flight
    bcc load_flight

    ; Only +3K. Set patch vector called by game.
    lda #$00
    sta model_patch
    lda #$04
    sta @(++ model_patch)

load_flight:
    ldy #<loader_cfg_message
    lda #>loader_cfg_message
    jmp tape_loader_start

txt_presents:
    @(ascii2petscii "presents")
txt_presents_end:

message_size = @(length (fetch-file (+ "obj/message." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_message:
    $00 $14
    <message_size @(++ >message_size)
    @(low *message-start*) @(high *message-start*)

loaded_patch3k:
    @(fetch-file (+ "obj/patch-3k." (downcase (symbol-name *tv*)) ".bin"))
