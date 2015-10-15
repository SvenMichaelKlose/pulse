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
    end
