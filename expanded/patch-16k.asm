start_hiscore_tune:
    lda #1
    sta current_sample
    lda #<audioloop
    sta sample_start2
    lda #>audioloop
    sta @(++ sample_start2)
    lda #<audioloop_end
    sta sample_end2
    lda #>audioloop_end
    sta @(++ sample_end2)
    jmp start_player2

sample_has_ended:
    lda current_sample
    and #7
    tax
    lda sample_pattern_start_l,x
    sta @(+ 1 mod_sample_ptr2)
    lda sample_pattern_start_h,x
    sta @(+ 2 mod_sample_ptr2)
    lda sample_pattern_end_l,x
    sta sample_end2
    lda sample_pattern_end_h,x
    sta @(++ sample_end2)
    inc current_sample
    rts


audioloop:
    @(fetch-file "obj/intermediate.pcm2")
audioloop_end:
audioloop2:
    @(fetch-file "obj/intermediate2.pcm2")
audioloop_end2:

current_sample: 0

sample_pattern_start_l:
    <audioloop
    <audioloop
    <audioloop
    <audioloop
    <audioloop2
    <audioloop2
    <audioloop2
    <audioloop2
sample_pattern_start_h:
    >audioloop
    >audioloop
    >audioloop
    >audioloop
    >audioloop2
    >audioloop2
    >audioloop2
    >audioloop2
sample_pattern_end_l:
    <audioloop_end
    <audioloop_end
    <audioloop_end
    <audioloop_end
    <audioloop_end2
    <audioloop_end2
    <audioloop_end2
    <audioloop_end2
sample_pattern_end_h:
    >audioloop_end
    >audioloop_end
    >audioloop_end
    >audioloop_end
    >audioloop_end2
    >audioloop_end2
    >audioloop_end2
    >audioloop_end2
