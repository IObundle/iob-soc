#include "iob_soc_conf.h"
#include "boot_conf.h"

#define CTR_ADDR (BOOT_BASE+(1<<IOB_SOC_ROM_ADDR_W))

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<IOB_SOC_RAM_ADDR_W)
addi sp, sp, %lo(1<<IOB_SOC_RAM_ADDR_W)

//call main
jal ra, main

//reboot to run bootloader
li s5, 6 //cpu_rst=1, boot=1, preboot=0
li s6, CTR_ADDR
sw s5, 0(s6)

ebreak
