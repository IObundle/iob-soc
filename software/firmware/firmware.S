#include "system.h"

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<FIRM_ADDR_W)
addi sp, sp, %lo(1<<FIRM_ADDR_W)

//call main
jal ra, main

//reboot to run bootloader
li s5, 3
#ifdef RUN_EXTMEM
li s6, BOOTCTR_BASE | EXTRA_BASE
#else
li s6, BOOTCTR_BASE
#endif
sw s5, 0(s6)//cpu_rst_req=1, boot=1

ebreak
