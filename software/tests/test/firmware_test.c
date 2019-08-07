#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"

#define DEVVAL 10

#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define UART_ADDRESS 0x70000000
#define Address_write 0x9004 //address where the writting starts
#define N 1000
volatile int * vect;

void main()
{ 
  int counter, reg = 0 ;
  unsigned char ledvar = 0;
  unsigned char Numb = 0;

  uart_init(UART_ADDRESS,DEVVAL);
   
  uart_write_wait();
  uart_puts("... Initializing program in main memory:\n");
  vect = (volatile int*) Address_write;

  for (counter = 0; counter < N; counter ++){
    vect[counter] = counter;
  }
  uart_write_wait();
  uart_puts("Wrote all numbers, the last printed: \n");
  uart_write_wait();
  uart_printf("%x\n", vect[N-1]);
  uart_write_wait();
  uart_puts("Verification of said numbers:\n");

  for (counter = 0; counter < N; counter ++){
    if (vect[counter] != counter){
      //    print("failed at: ");
      //print_hex (vect[counter], 5);
      //print("\n");
      uart_write_wait();
      uart_printf("fail:%x\n", counter);
    }
  }
  uart_write_wait();
  uart_puts("End of program\n");

  while(1);

}
