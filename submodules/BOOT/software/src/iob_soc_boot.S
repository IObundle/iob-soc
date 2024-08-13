#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"
#include "iob_soc_system.h"

// Can't include iob_bootctr_swreg.h because the assembler doesn't recognize stdint.h,
// so define the constants here instead (these are address offsets).

.section .init
.globl main

  //set stack pointer
  lui sp, %hi(1 << IOB_SOC_MEM_ADDR_W)
  addi sp, sp, %lo(1 << IOB_SOC_MEM_ADDR_W)

  //call main
  jal ra, main

  // Jump to the firmware
  li x5, 0x0
  jalr x0, 0(x5)
