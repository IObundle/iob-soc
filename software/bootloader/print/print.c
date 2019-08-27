#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"
#include "system.h"

#define DIVVAL 868

#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200

#define N 4096 

volatile int* DDR_MEM;

void main()
{ 
  int fail_counter, i = 0;
  
  DDR_MEM = (volatile int*) MAINMEM_BASE;

  uart_init(UART_BASE,UART_CLK_FREQ/UART_BAUD_RATE);

  uart_puts ("\nThis is a DDR Test!\n");
  uart_printf("Writting vector of size %d to DDR...\n", N);

  for (i = 1 ; i < N; i ++){
    DDR_MEM[i] = i;
  }
    uart_printf("Done!\n");

  for (; i < N; i ++){
    if(DDR_MEM[i] != i){
      uart_printf("Fail %d: expected %x from DDR, actual value %x\n", fail_counter, i, DDR_MEM[i]);
    }
  }
  
  uart_printf("Done!\n");
  uart_printf("Verification complete with %d failures.\n", fail_counter);
}
