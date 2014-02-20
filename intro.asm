intro:
    jsr clear_screen
    lda #8+blue     ; Screen and border.
    sta $900f
    lda #red*16     ; Auxiliary color.
    sta $900e
    lda #%11111100  ; Our charset.                                              
    sta $9005

    jmp start_main

txt_intro:
    .asc "Pulse",0
    .asc "Copyright (c) 2014",0
