flight_loader_start:
    org $1e00

flight_loader:
    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ldy #<loader_cfg_flight
    lda #>loader_cfg_flight
    jmp tape_loader_start

flight_size = @(length (fetch-file (+ "obj/flight.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_flight:
    $00 $10
    <flight_size @(++ >flight_size)
    $02 $10
