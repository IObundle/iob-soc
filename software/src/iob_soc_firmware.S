#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"

// Can't include iob_soc_boot_conf.h because the assembler doesn't recognize stdint.h,
// so define the constants here instead (these are address offsets).
#define IOB_SOC_BOOT_CTR 0

#define CTR_ADDR (BOOT0_BASE+IOB_SOC_BOOT_CTR)

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<IOB_SOC_SRAM_ADDR_W)
addi sp, sp, %lo(1<<IOB_SOC_SRAM_ADDR_W)

//call main
jal ra, main

li s5, 6 //cpu_rst=1, boot=1, preboot=0
li s6, CTR_ADDR
sw s5, 0(s6)

ebreak
