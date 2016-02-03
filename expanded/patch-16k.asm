start_hiscore_tune:
    lda #<audioloop
    sta sample_start2
    lda #>audioloop
    sta @(++ sample_start2)
    lda #<audioloop_end
    sta sample_end2
    lda #>audioloop_end
    sta @(++ sample_end2)
    jmp start_player2

audioloop:
    @(fetch-file "obj/intermediate.pcm2")
audioloop_end:
audioloop2:
    @(fetch-file "obj/intermediate2.pcm2")
audioloop_end2:
