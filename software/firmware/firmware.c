#include "system.h"
#include "iob-uart.h"

#define UART (UART_BASE<<(DATA_W-N_SLAVES_W))
#define SOFT_RESET (SOFT_RESET_BASE<<(ADDR_W-N_SLAVES_W))

int main()
{ 
  uart_init(UART,UART_CLK_FREQ/UART_BAUD_RATE);   

  uart_printf("Hello world!\n");

  uart_txwait();

  //uncomment the below to reset and start from boot ram
  //MEMSET(SOFT_RESET, 0, 3);

  return 0;
}
