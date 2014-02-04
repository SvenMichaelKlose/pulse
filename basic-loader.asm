* = $0fff

load_address:
    .word $1001

    .word basic_end
    .word 1
    .byte $9e
    .asc "4109"
    .byte 0
basic_end:
    .word 0
