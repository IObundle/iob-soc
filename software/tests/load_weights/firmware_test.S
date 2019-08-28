
.section .init
.global main


/* set stack pointer */
//lui sp, %hi(16*1024)
//addi sp, sp, %lo(16*1024)
lui sp, %hi(0x9000)
addi sp, sp, %lo(0xF0000) 


//.equ STACK_ADDR, 0x800
//li sp, STACK_ADDR 


/* call main */
jal ra, main

/* break */
ebreak
