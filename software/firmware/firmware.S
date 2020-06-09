#include "system.h"
#include "firmware.h"

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<FIRM_ADDR_W)
addi sp, sp, %lo(1<<FIRM_ADDR_W)

//call main
jal ra, main


//reboot        
#ifdef USE_BOOT
li s5, 3
li s6, BOOTCTR_BASE
sw s5, 0(s6)//cpu_rst_req=1, boot=1
#endif

ebreak
