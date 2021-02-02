#include "stdlib.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"

int main()
{
  //init uart 
  uart_init(UART_BASE,FREQ/BAUD);   
  uart_printf("\n\n\nHello world number %d!\n\n\n", 1);
 
  printf_("Value of Pi = %f\n\n", 3.1415);
  
  uart_finish();
  
}
