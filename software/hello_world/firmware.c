#include "system.h"
#include "iob-uart.h"

#define UART (UART_BASE<<(DATA_W-N_SLAVES_W))

int main()
{ 
  uart_init(UART,UART_CLK_FREQ/UART_BAUD_RATE);   

  uart_puts("Hello world!\n");

  return 0;
}
