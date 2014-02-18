lowmem_end:
* = lowmem+lowmem_end-$200
init_end:
    .dsb realstart-init_end, 0

* = realstart
start_main:
