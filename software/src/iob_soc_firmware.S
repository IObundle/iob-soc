#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"
#include "iob_soc_system.h"

// Can't include iob_bootctr_swreg.h because the assembler doesn't recognize stdint.h,
// so define the constants here instead (these are address offsets).
#define IOB_BOOTCTR_CTR_ADDR 16777216
#define IOB_BOOTCTR_CPU_RST_ADDR 16777217

.section .init
.globl main

  //set stack pointer
  lui sp, %hi(1<<IOB_SOC_SRAM_ADDR_W)
  addi sp, sp, %lo(1<<IOB_SOC_SRAM_ADDR_W)

  //call main
  jal ra, main

  //reboot to run bootloader

  li s5, 1
  li s6, BOOTCTR0_BASE + IOB_BOOTCTR_CPU_RST_ADDR
  sb s5, 0(s6)

  li s5, 0
  li s6, BOOTCTR0_BASE + IOB_BOOTCTR_CPU_RST_ADDR
  sb s5, 0(s6)

  li s5, 1
  li s6, BOOTCTR0_BASE + IOB_BOOTCTR_CTR_ADDR
  sb s5, 0(s6)

forever:
  // Keep this here, for the CPU to wait until the reset pulse is triggered
  j forever
