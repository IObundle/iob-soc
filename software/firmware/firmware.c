#include "system.h"
#include "iob-uart.h"

int main()
{ 
  uart_init(UART_BASE,UART_CLK_FREQ/UART_BAUD_RATE);   
  uart_printf("Hello world!\n");
}
