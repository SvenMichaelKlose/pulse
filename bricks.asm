scrbricks_i:.byte 0, 1
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 4, 5
            .byte $ff
scrbricks_x:.byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 28, 47
scrbricks_y:.byte 7, 7
            .byte 8, 8
            .byte 9, 9
            .byte 10, 10
            .byte 11, 11
            .byte 12, 12
            .byte 13, 13
            .byte 14, 14
            .byte 15, 15
            .byte 16, 16
            .byte 17, 17
            .byte 18, 18
            .byte 19, 19
            .byte 20, 20
            .byte 21, 21
            .byte 22, 22

bricks_c:   .byte 0, 0, 0, 0, 0, 0
bricks_col: .byte yellow+8, yellow+8, yellow+8,    yellow+8,    yellow+8,    yellow+8
bricks_l:   .byte 0,        <bg_t,    0,           <background, <background, <bg_t
bricks_m:   .byte <bg_tl,   <bg_tr,   <bg_l,       <bg_r,       <bg_dl,      <bg_dr
bricks_r:   .byte <bg_t,    0,        <background, 0,           <bg_t,       <background
