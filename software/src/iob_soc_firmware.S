#include "iob_soc_system.h"
#include "iob_soc_conf.h"

.section .init
.global main

//set stack pointer
#ifdef IOB_SOC_USE_EXTMEM //need to set MSB to address external memory
lui sp, %hi(EXTRA_BASE | 1<<IOB_SOC_MEM_ADDR_W)
addi sp, sp, %lo(EXTRA_BASE | 1<<IOB_SOC_MEM_ADDR_W)
#else
lui sp, %hi(1<<IOB_SOC_SRAM_ADDR_W)
addi sp, sp, %lo(1<<IOB_SOC_SRAM_ADDR_W)
#endif

//call main
jal ra, main

//reboot to run bootloader
li s5, 3 //cpu_rst_req=1, boot=1
li s6, BOOTCTR_BASE
sw s5, 0(s6)

ebreak
