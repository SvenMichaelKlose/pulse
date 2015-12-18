    org $1000
    $02 $10

    ldx #0
l:  lda loaded_intro,x
    sta intro_start,x
    lda @(+ 256 loaded_intro),x
    sta @(+ 256 intro_start),x
    lda @(+ 512 loaded_intro),x
    sta @(+ 512 intro_start),x
    inx
    bne -l
    jmp intro_start
