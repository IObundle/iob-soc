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

#define MEM_JUMP 0x6FFFFFFC 
#define PROG_SIZE 4096 

volatile int* MAIN_MEM;
volatile int* PC_SOFT_RESET;

void main()
{ 
  int counter, i = 0;
  int a;
  char* uart_char;
  int*  int_uart;     
  char buf[4];
  unsigned char temp;
  int line=0;
  MAIN_MEM = (volatile int*) MAINMEM_BASE;

  uart_init(UART_BASE,UART_CLK_FREQ/UART_BAUD_RATE);

  uart_puts ("\nLoad Program through UART to Main Memory...\n");
  uart_putc(0x11);

  for (i = 0 ; i < PROG_SIZE; i ++){
    line = 0;
    for (counter = 3; counter >= 0 ; counter--) {
      //read the byte to a char and append it to the line
      temp = uart_getc();
      line+=temp << (8*counter); //number of shitfs = number of bits in a byte

    }
      
    MAIN_MEM[i] = line;
  }

  uart_puts("\nProgram copy completed... Printing final copy:\n");
  for (i = 0 ; i < PROG_SIZE; i++){
    uart_printf("%x: ", i);//printing int instead of byte address
    uart_printf("%x\n", MAIN_MEM[i]);
  }

  uart_puts("\nPreparing to start the Main Memory program...\n");    

  *((volatile int*) MEM_JUMP) = 1;
}
