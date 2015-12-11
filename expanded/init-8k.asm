preshifted_sprites = @(- #x4000 #x480)

    $02 $20
    org $2002

    ; Check if there's minimum +8K RAM.
    lda model
    lsr
    beq +i

    ; Set patch vector called by game.
    lda #<patch8k
    sta model_patch
    lda #>patch8k
    sta @(++ model_patch)

i:  rts
