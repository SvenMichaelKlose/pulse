    org $1000
    $02 $10

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
    ldy #<loader_cfg_flight
    lda #>loader_cfg_flight
    jmp tape_loader_start

flight_size = @(length (fetch-file (+ "obj/flight.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_flight:
    $00 $10
    <flight_size @(++ >flight_size)
    $02 $10

loaded_patch3k:
    @(fetch-file (+ "obj/patch-3k." (downcase (symbol-name *tv*)) ".bin"))
