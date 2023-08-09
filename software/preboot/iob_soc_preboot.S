#include "iob_soc_conf.h"
#include "boot_conf.h"

#define BOOTROM (BASE+0x100)
#define BOOTRAM ((1<<31) + (1<<MEM_ADDR_W) - (1<<BOOTROM_ADDR_W))
#define LENGTH (1 << BOOTROM_ADDR_W)
#define CTR_ADDR (BOOT_BASE+(1<<BOOTROM_ADDR_W))
        
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
li s5, 6 //cpu_rst_req=1, bootload=1, preload=0
li s6, CTR_ADDR
sw s5, 0(s6)

ebreak
