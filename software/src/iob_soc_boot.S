#include "iob_soc_system.h"
#include "iob_soc_conf.h"

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<IOB_SOC_SRAM_ADDR_W)
addi sp, sp, %lo(1<<IOB_SOC_SRAM_ADDR_W)

//call main
jal ra, main

//reboot to run firmware
li s5, 2 //cpu_rst_req=1, boot=0
li s6, BOOTCTR_BASE
sw s5, 0(s6)

ebreak
