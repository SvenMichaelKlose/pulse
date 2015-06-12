    jsr draw_sprites
if @*virtual?*
    $22 2   ; Update display.
end

increment_framecounter:
    inc framecounter
    bne +n
    inc framecounter_high
n:

    jsr grenade
    jmp mainloop
