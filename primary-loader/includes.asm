#define IRQ_LOADER_EFFECT

timer_value = $28 * 8

#include "zeropage.asm"

#include "../bender/vic-20/vic.asm"
#include "../bender/vic-20/basic-loader.asm"

#include "lens.asm"
#include "main.asm"

#include "../shared/start-irq-loader.asm"
loaded_irq_loader:
* = screen
#include "../shared/irq-loader.asm"
#include "waiter.asm"
