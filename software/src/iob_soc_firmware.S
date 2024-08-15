#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"
#include "iob_soc_system.h"

.section .init
.globl main

  //set stack pointer
  lui sp, %hi(1 << IOB_SOC_MEM_ADDR_W)
  addi sp, sp, %lo(1 << IOB_SOC_MEM_ADDR_W)

  //call main
  jal ra, main

  // Jump to the pre-bootloader
  li x5, 0x80000000
  jalr x0, 0(x5)
