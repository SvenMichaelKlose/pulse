    jsr draw_sprites

increment_framecounter:
    inc framecounter
    bne +n
    inc framecounter_high
n:

    jsr grenade
    jmp mainloop
