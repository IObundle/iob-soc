#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"

#define DIVVAL 868

#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define UART_ADDRESS 0x70000000
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFC 
#define PROG_SIZE 4096 

volatile int* MAIN_MEM;
volatile int* PROG_MEM;
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
  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;

  uart_init(UART_ADDRESS,DIVVAL);

  uart_write_wait();
  uart_puts ("\nLoad Program through UART to Main Memory...\n");
  uart_write_wait();
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

  uart_write_wait();
  uart_puts("\nProgram copy completed... Printing final copy:\n");
  for (i = 0 ; i < PROG_SIZE; i++){
    uart_write_wait();
    uart_printf("%x: ", i);//printing int instead of byte address
    uart_write_wait();
    uart_printf("%x\n", MAIN_MEM[i]);
  }
  uart_write_wait();
  uart_puts("\nPreparing to start the Main Memory program...\n");    

  *((volatile int*) MEM_JUMP) = 1;
}
