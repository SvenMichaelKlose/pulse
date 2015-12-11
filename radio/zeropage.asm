screen = $1e00
colors = $9600

    org 0

    data

tape_ptr:           0 0
tape_counter:       0 0
tape_callback:      0 0
tape_current_byte:  0
tape_bit_counter:   0
tape_old_irq:       0 0
tape_leader_countdown: 0

s:                  0 0
d:                  0 0
scrx:               0
scry:               0
curcol:             0
last_random_value:  0

; Audio loader.
current_low:        0
average:            0 0
tleft:              0
dleft:              0
do_play_radio:      0

; Flight.
last_audio_raster:  0
rr_sample:          0
curchar:            0

    end
