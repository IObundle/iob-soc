#include "system.h"
#include "iob-uart.h"
#include "iob-cache.h"

int main()
{ 
  uart_init(UART,UART_CLK_FREQ/UART_BAUD_RATE);   

  //uart_printf("Hello world!\n");
  //uart_puts("Hello world!\n");

  //uart_txwait();

  //uncomment the below to reset and start from boot ram
  //MEMSET(SOFT_RESET, 0, 3);

  return 0;
}
