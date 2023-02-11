#include "iob_soc_system.h"
#include "iob_soc_conf.h"

#define BOOTROM 0x40000000
#define RAM (1<<31)
#define BOOTRAM ((1<<SRAM_ADDR_W)-(1<<BOOTROM_ADDR_W))
#define LENGTH (1 << BOOTROM_ADDR_W)
#define STACK (RAM + BOOTRAM + LENGTH - 4)
        
.section .init
.globl _start

_start:
  li x1, LENGTH
  li x2, BOOTROM
  li x3, BOOTRAM
  li x5, RAM + BOOTRAM

copy_loop:
  lw x4, 0(x2)
  sw x4, 0(x5)
  addi x2, x2, 4
  addi x3, x3, 4
  addi x1, x1, -1
  bne x1, x0, copy_loop

.section .text
.global main

//set stack pointer
lui sp, %hi(STACK)
addi sp, sp, %lo(STACK)

//call main
jalr ra, 0(x5)

//reboot to run firmware
li s5, 2 //cpu_rst_req=1, boot=0
li s6, BOOTCTR_BASE
sw s5, 0(s6)

ebreak
