#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"

#define DIVVAL 10

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

  //uart_write_wait();
  // reg_uart_clkdiv = 868;
  //reg_uart_clkdiv = 2170;
  /*

    for (counter = 0; counter < PROG_SIZE; counter ++){
    MAIN_MEM[counter] = PROG_MEM[counter];
    };

    //uart_puts("S\n");
    //uart_puts("Program copy completed. Starting to read from Main Memory...\n");
    //uart_wait(); 
    print("Program copy completed. Starting to read from Main Memory...\n");


    *((volatile int*) MEM_JUMP) = 1;
    }
  */
  uart_write_wait();
  uart_puts ("\nLoad Program throught UART to Main Memory...\n");
  uart_write_wait();
  uart_putc(0x11);

  for (i = 0 ; i < PROG_SIZE; i ++){
    line = 0;
    for (counter = 3; counter >= 0 ; counter--) {

      //	MAIN_MEM[(8*i) + counter] = getchar();
      //uart_read_wait();
      uart_read_wait();

      //read the byte to a char and append it to the line
      temp = uart_getc();
      line+=temp << (8*counter); //number of shitfs = number of bits in a byte


      //MAIN_MEM[(4*i) + counter] = uart_getc();
      //	print("\nValue sent: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      /*
	Some print manipulation
      if (MAIN_MEM [(4*i) + counter] >='0'  && MAIN_MEM [(4*i) + counter] <= '9'){
	MAIN_MEM [(4*i) + counter] = MAIN_MEM[(4*i) + counter] - 48;
      }else{
	MAIN_MEM [(4*i) + counter] = MAIN_MEM [(4*i) + counter] - 87;
      }
      */
      //	print(" - char of: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      //	uart_printf("%x", MAIN_MEM[(8*i) + counter]);
    }
    // uart_puts("\n");
      
    MAIN_MEM[i] = line;
    /*
    for (counter = 0; counter < 4; counter ++){
      //	print("\n");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      MAIN_MEM[(4*i) + counter] = MAIN_MEM[(4*i) + counter] << (2*counter);
      //	print(" - shifted value: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 8);    
    }
    */
    /*
    MAIN_MEM[i] = MAIN_MEM [4*i]; //puts the instruction in order (from address 8*i to i)
    for (counter = 1; counter < 4; counter ++){
      MAIN_MEM[i] = MAIN_MEM[i] + MAIN_MEM[(4*i) + counter];
    }
    */
    // print("\nFinal value: ");
    //print_hex(MAIN_MEM[i], 8);
    //print("Line: ");
    // print_hex(i, 3);
    //print("\n");
  }
  uart_write_wait();
  uart_puts("\nProgram copy completed... Printing final copy:\n");
  for (i = 0 ; i < PROG_SIZE; i++){
    // print_hex (i, 3);
    // print (": ");
    // print_hex (MAIN_MEM[i], 8);
    // print("\n");
    uart_write_wait();
    uart_printf("%x: ", i);//printing int instead of byte address
    uart_write_wait();
    uart_printf("%x\n", MAIN_MEM[i]);
  }
  uart_write_wait();
  uart_puts("\nPreparing to start the Main Memory program...\n");    

  *((volatile int*) MEM_JUMP) = 1;
  //counter = PC_SOFT_RESET[0];
}





