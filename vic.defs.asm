screensize = 22*23
charset_upcase = $8000
charset_upcase_reversed = $8400
charset_locase = $8800
charset_locase_reversed = $8c00

screen  = $1e00
colors  = $9600

vic_charset_1000 = %11111100
vic_charset_uplo = %11110010

vicreg_interlace_horigin        = $9000
vicreg_vorigin                  = $9001
vicreg_screenhi_columns         = $9002
vicreg_rasterhi_rows_charsize   = $9003
vicreg_rasterlo                 = $9004
vicreg_screenlo_charset         = $9005
vicreg_hpen                     = $9006
vicreg_vpen                     = $9007
vicreg_paddle1                  = $9008
vicreg_paddle2                  = $9009
vicreg_bass                     = $900a
vicreg_alto                     = $900b
vicreg_soprano                  = $900c
vicreg_noise                    = $900d
vicreg_auxcol_volume            = $900e
vicreg_screencol_reverse_border = $900f

black   = 0
white   = 1
red     = 2
cyan    = 3
purple  = 4
green   = 5
blue    = 6
yellow  = 7
orange  = 8
lorange = 9
pink    = 10
lcyan   = 11
lpurple = 12
lgreen  = 13
lblue   = 14
lyellow = 15

joy_fire    = %00100000
joy_up      = %00000100
joy_down    = %00001000
joy_left    = %00010000
