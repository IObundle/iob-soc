#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"
#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define UART_ADDRESS 0x70000000
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFC 
#define PROG_SIZE 2048 

volatile int* MAIN_MEM;
volatile int* PROG_MEM;
volatile int* PC_SOFT_RESET;

void main()
{ 
  int counter;
        

  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;
  PC_SOFT_RESET = (volatile int*) MEM_JUMP;

  //uart_reset();
  //reg_uart_clkdiv = 868;
  //reg_uart_clkdiv = 2170;
  uart_init(UART_ADDRESS,(UART_CLK_FREQ/UART_BAUD_RATE));
  //uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  //uart_wait();  
 
  //uart_puts("C\n");
  uart_write_wait();
  uart_puts("Copying Program to Main Memory...\n");
  //uart_wait(); 
  //print ("Copying Program to Main Memory...\n");
  //print ("A\n");

  for (counter = 0; counter < PROG_SIZE; counter ++){
    MAIN_MEM[counter] = PROG_MEM[counter];
  };

  //  uart_puts("S\n");
  uart_write_wait();
  uart_puts("Program copy completed. Starting to read from Main Memory...\n");
  //uart_wait(); 
  //print("Program copy completed. Starting to read from Main Memory...\n");
  //  print ("B\n");
  //*((volatile int*) MEM_JUMP) = 1;
  counter = PC_SOFT_RESET[0];
}
