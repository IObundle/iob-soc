#include "stdlib.h"
#include <stdio.h>
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"

int main()
{
  //init uart
  uart_init(UART_BASE,FREQ/BAUD);   
  uart_puts("\n\n\nHello world!\n\n\n");
  printf("Value of Pi = %f\n\n", 3.1415);
  uart_finish();
}
