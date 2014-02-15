lowmem_end:
* = lowmem+lowmem_end-$200
init_end:
    .dsb realstart-init_end, $ea

* = realstart
start_main:
