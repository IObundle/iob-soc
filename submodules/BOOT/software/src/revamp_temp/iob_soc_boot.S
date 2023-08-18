#include "iob_soc_boot_swreg.h"
#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"

#define CTR_ADDR (BOOT0_BASE+IOB_SOC_BOOT_CTR)

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<MEM_ADDR_W)
addi sp, sp, %lo(1<<MEM_ADDR_W)

//call main
jal ra, main

//reboot to run firmware
li s5, 2
li s6, CTR_ADDR
sw s5, 0(s6)

ebreak
