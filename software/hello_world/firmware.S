#include "system.h"

.section .init
.global main

/* set stack pointer */
lui sp, %hi(4*  (1<<RAM_ADDR_W))
addi sp, sp, %lo(4*(1<<RAM_ADDR_W))

/* call main */
jal ra, main

/* break */
ebreak
