#include "iob_bootctr_conf.h"
#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"

// Can't include iob_bootctr_swreg.h because the assembler doesn't recognize stdint.h,
// so define the constants here instead (these are address offsets).
#define IOB_BOOTCTR_ROM 0
#define IOB_BOOTCTR_CTR 0
#define IOB_BOOTCTR_CPU_RST 1

#define BOOTROM (BOOTCTR0_BASE + IOB_BOOTCTR_ROM)
#define BOOTRAM ((1 << 31) + (1 << IOB_SOC_MEM_ADDR_W) - (1 << IOB_BOOTCTR_BOOT_ROM_ADDR_W))
//#define BOOTRAM ((1 << 31) + (1 << IOB_SOC_MEM_ADDR_W))
//#define BOOTRAM (1 << 31)
#define LENGTH (1 << IOB_BOOTCTR_BOOT_ROM_ADDR_W)

.section .init
.globl _start

_start:
  li x1, LENGTH
  li x2, BOOTROM
  li x3, BOOTRAM

copy_loop:
  lw x4, 0(x2)
  sw x4, 0(x4)
  addi x2, x2, 4
  addi x3, x3, 4
  addi x1, x1, -1
  bne x1, x0, copy_loop

//reboot to run bootloader
li s5, 1
li s6, BOOTCTR0_BASE + IOB_BOOTCTR_CTR
sw s5, 0(s6)

li s5, 1
li s6, BOOTCTR0_BASE + IOB_BOOTCTR_CPU_RST
sw s5, 0(s6)

ebreak
