abs:
    bpl abs_end
neg:eor #$ff
    clc
    adc #1
abs_end:
    rts
