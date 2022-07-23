#include "system.h"

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<FIRM_ADDR_W)
addi sp, sp, %lo(1<<FIRM_ADDR_W)

//call main
jal ra, main

//reboot to run bootloader
li s5, 3 //cpu_rst_req=1, boot=1
#ifdef RUN_EXTMEM //need to set MSB to address internal mem and boot controller
li s6, EXTRA_BASE | BOOTCTR_BASE
#else
li s6, BOOTCTR_BASE
#endif
sw s5, 0(s6)

ebreak
