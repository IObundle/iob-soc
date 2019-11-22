
.section .init
.global main

/* set stack pointer */
lui sp, %hi(4*4096)
addi sp, sp, %lo(4*4096)

//.equ STACK_ADDR, 0x800
//li sp, STACK_ADDR


/* call main */
jal ra, main

/* break */
ebreak
