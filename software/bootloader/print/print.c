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

  uart_puts ("\nHello! This is a Versat Test!\n");
  uart_puts("Init Versat 1\n");

  for (i = 1 ; i < 6; i ++){
    uart_printf("val%x = %x\n", i, i);
  }
    uart_printf("\n");

  for (; i < 11; i ++){
    uart_printf("val%x = %x\n", i, i);
  }

    uart_printf("\n");
  for (i = 7 ; i < 16; i+=2){
    uart_printf("%d\n", i);
  }
  uart_puts("Done\n");
}
