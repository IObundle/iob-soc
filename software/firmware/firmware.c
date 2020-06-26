#include "system.h"
#include "iob-uart.h"

int main()
{ 
  //init uart 
  uart_init(UART_BASE,FREQ/BAUD);   

  uart_printf("\n\n\nHello world!\n\n\n");

  //hang up
  uart_endtext();
    
}
