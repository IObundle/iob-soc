#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"
#include "system.h"

#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE BAUD //BAUD passed from Makefile
#define MEM_JUMP 0x6FFFFFFC
#define PROG_SIZE 4096 

volatile int* MAIN_MEM;
volatile int* PC_SOFT_RESET;
volatile int* DDR_MEM;

void main()
{ 
  int counter, i = 0;
  int a;
  char* uart_char;
  int*  int_uart;
  char buf[4];
  unsigned char temp;
  int line=0;
  int acc = 0;
  MAIN_MEM = (volatile int*) MAINMEM_BASE; //AUXMEM is slave 1
  //DDR_MEM = (volatile int*) AUXMEM_BASE; //cache is slave 4

  uart_init(UART_BASE,UART_CLK_FREQ/UART_BAUD_RATE);

  uart_puts ("\nLoad Program through UART to Main Memory...\n");
  uart_printf("Writing starts at %x\n", MAIN_MEM);
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

#ifdef DDR
  uart_printf("\n\n******** DDR TEST *******\n\n");
  
  uart_printf("Writing from address: %x\n", DDR_MEM);

  for(i=0; i< PROG_SIZE;i++){
    DDR_MEM[i] = i;
  }

  for(i=0;i< PROG_SIZE; i++){
    if(DDR_MEM[i] != i) { 
      uart_printf("fail: %x\n", i);
      acc++;
   }
  }

  uart_printf("Read from address: %x with %d errors\n", DDR_MEM, acc);
#endif

  uart_puts("\nPreparing to start the Main Memory program...\n");    

  *((volatile int*) MEM_JUMP) = 1;
}
