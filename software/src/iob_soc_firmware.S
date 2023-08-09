#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"
#include "boot_conf.h"

#define CTR_ADDR (BOOT0_BASE+(1<<BOOTROM_ADDR_W))

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<MEM_ADDR_W)
addi sp, sp, %lo(1<<MEM_ADDR_W)

//call main
jal ra, main

li s5, 6 //cpu_rst=1, boot=1, preboot=0
li s6, CTR_ADDR
sw s5, 0(s6)

ebreak
