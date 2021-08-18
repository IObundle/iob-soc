//#include "stdlib.h"
//#include <stdio.h>
//#include "system.h"
//#include "periphs.h"
//#include "iob-uart.h"
//#include "printf.h"

//int main()
//{
  //init uart
  // uart_init(UART_BASE,FREQ/BAUD);   
  // uart_puts("\n\n\nHello world!\n\n\n");
  // printf("Value of Pi = %f\n\n", 3.1415);
  // uart_finish();
//}
//
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"
#include "iob_timer.h"

int main()
{
  unsigned long long elapsed;
  unsigned int elapsedu;

  //init timer and uart
  timer_init(TIMER_BASE);
  uart_init(UART_BASE, FREQ/BAUD);

  printf("\nHello world!\n");

  //read current timer count, compute elapsed time
  elapsed  = timer_get_count();
  elapsedu = timer_time_us();

  printf("\nExecution time: %d clock cycles\n", (unsigned int) elapsed);
  printf("\nExecution time: %dus @%dMHz\n\n", elapsedu, FREQ/1000000);

  uart_finish();
}
