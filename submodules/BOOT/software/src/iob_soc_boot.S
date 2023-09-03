#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"

// Can't import iob_soc_boot_swreg.h because it includes stdint.h, which the assembler doesn't like, so goes manual.
#define IOB_SOC_BOOT_CTR 0

.section .init
.global main

//set stack pointer
lui sp, %hi(1 << IOB_SOC_SRAM_ADDR_W)
addi sp, sp, %lo(1 << IOB_SOC_SRAM_ADDR_W)

//call main
jal ra, main

//reboot to run firmware
li s5, 2
li s6, BOOT0_BASE + IOB_SOC_BOOT_CTR
sw s5, 0(s6)

ebreak
