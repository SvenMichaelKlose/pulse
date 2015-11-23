; Turn cosmic radiation into a random number.
block
random:
    lda last_random_value
    asl
    adc #0
    eor vicreg_rasterhi
    eor #1
    sta last_random_value
    rts
end block
