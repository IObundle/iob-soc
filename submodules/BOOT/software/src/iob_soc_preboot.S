#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"
#include "iob_soc_system.h"

// Can't include iob_bootctr_swreg.h because the assembler doesn't recognize stdint.h,
// so define the constants here instead (these are address offsets).
#define IOB_BOOTCTR_ROM_ADDR 0

#define BOOTROM (BOOTCTR0_BASE + IOB_BOOTCTR_ROM_ADDR)
#define LENGTH (1 << IOB_SOC_BOOTROM_ADDR_W)

.section .init
.globl _start

_start:
  li x1, LENGTH + 1
  li x2, BOOTROM
  // Below, -4 because it was only starting to write at 0x4 for some reason
  li x3, BOOTLDR_ADDR - 4

copy_loop:
  lw x4, 0(x2)
  sw x4, 0(x3)
  addi x2, x2, 4
  addi x3, x3, 4
  addi x1, x1, -1
  bne x1, x0, copy_loop

  // Jump to the bootloader
  li x5, BOOTLDR_ADDR
  jalr x0, 0(x5)
