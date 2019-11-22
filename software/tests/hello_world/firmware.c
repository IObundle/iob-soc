#include "system.h"
#include "iob-uart.h"

void main()
{ 
  uart_init(UART_BASE,UART_CLK_FREQ/UART_BAUD_RATE);
   
  uart_puts("Hello world!\n");

  while(1);

}
