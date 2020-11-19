#include "interconnect.h"
#include "iob-uart.h"

//base address
static int base;

//UART functions
void uart_init(int base_address, int div) {
  //capture base address for good
  base = base_address;

  //pulse soft reset 
  IO_SET(base, UART_SOFT_RESET, 1);
  IO_SET(base, UART_SOFT_RESET, 0);

  //Set the division factor div
  //div should be equal to round (fclk/baudrate)
  //E.g for fclk = 100 Mhz for a baudrate of 115200 we should uart_setdiv(868)
  IO_SET(base, UART_DIV, div);
  IO_SET(base, UART_TXEN, 1);
  IO_SET(base, UART_RXEN, 1);
}

int uart_getdiv()
{
  return (IO_GET(base, UART_DIV));
}

//tx functions
void uart_txwait() {
  while(IO_GET(base, UART_WRITE_WAIT));
}

int uart_txstatus() {
  return (!IO_GET(base, UART_WRITE_WAIT));
}

void uart_putc(char c) {
  while(IO_GET(base, UART_WRITE_WAIT));
  IO_SET(base, UART_DATA, (int)c);
}

void uart_rxwait() {
  while(!IO_GET(base, UART_READ_VALID));
}

int uart_rxstatus() {
  return (IO_GET(base, UART_READ_VALID));
}

char uart_getc() {
  while(!IO_GET(base, UART_READ_VALID));
  return( (char) IO_GET(base, UART_DATA));
}

void uart_sleep (int n)  {
  uart_txwait();
  IO_SET(base, UART_TXEN, 0);
   for (int i=0; i<n; i++)
    uart_putc('c');
  uart_txwait();
  IO_SET(base, UART_TXEN, 1);
}
