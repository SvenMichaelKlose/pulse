    org $2000
    $02 $20

    ; Set patch vector called by game.
    lda #<patch8k
    sta model_patch
    lda #>patch8k
    sta @(++ model_patch)

    rts
