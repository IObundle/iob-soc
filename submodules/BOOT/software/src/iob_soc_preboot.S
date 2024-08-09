#include "iob_bootctr_conf.h"
#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"
#include "iob_soc_system.h"

// Can't include iob_bootctr_swreg.h because the assembler doesn't recognize stdint.h,
// so define the constants here instead (these are address offsets).
#define IOB_BOOTCTR_ROM_ADDR 0
#define IOB_BOOTCTR_CTR_ADDR 16777216
#define IOB_BOOTCTR_CPU_RST_ADDR 16777217

#define BOOTROM (BOOTCTR0_BASE + IOB_BOOTCTR_ROM_ADDR)
#define BOOTRAM ((1 << IOB_SOC_MEM_ADDR_W) - (1 << IOB_BOOTCTR_BOOT_ROM_ADDR_W))
#define LENGTH (1 << IOB_BOOTCTR_BOOT_ROM_ADDR_W)

.section .init
.globl _start

_start:
  li x1, LENGTH
  li x2, BOOTROM
  // Below, -4 because it was only starting to write at 0x4 for some reason
  li x3, BOOTRAM - 4

copy_loop:
  lw x4, 0(x2)
  sw x4, 0(x3)
  addi x2, x2, 4
  addi x3, x3, 4
  addi x1, x1, -1
  bne x1, x0, copy_loop

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

// Keep this here, for the CPU to wait until the reset pulse is triggered
forever:
  j forever
