abs:
    bpl _abs_end
neg:eor #$ff
    clc
    adc #1
_abs_end:
    rts
