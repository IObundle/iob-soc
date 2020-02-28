#include "system.h"

.section .init
.global main

/* set stack pointer */
lui sp, %hi(1<<MAINRAM_ADDR_W)
addi sp, sp, %lo(1<<MAINRAM_ADDR_W)

/* call main */
jal ra, main

/* break */
ebreak
