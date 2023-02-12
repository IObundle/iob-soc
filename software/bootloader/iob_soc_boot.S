#include "iob_soc_system.h"
#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"

.section .init
.global main

//set stack pointer
lui sp, %hi(1<<BOOTROM_ADDR_W)
addi sp, sp, %lo(1<<BOOTROM_ADDR_W)

//call main
jal ra, main

//reboot to run firmware
li s5, 4 //cpu_rst_req=1, bootload=0, preload=0
li s6, BOOT0_BASE
sw s5, 0(s6)

ebreak
