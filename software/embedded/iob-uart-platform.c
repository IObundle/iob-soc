#include "interconnect.h"
#include "iob-uart.h"

//base address
static int base;

//UART functions
void uart_init(int base_address, int div) {
  //capture base address for good
  base = base_address;

  //pulse soft reset 
  IO_SET(base, UART_SOFTRESET, 1);
  IO_SET(base, UART_SOFTRESET, 0);

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
void uart_txen(int val) {
  IO_SET(base, UART_TXEN, val);
}

void uart_txwait() {
  while(!IO_GET(base, UART_TXREADY));
}

int uart_istxready() {
  return (IO_GET(base, UART_TXREADY));
}

void uart_putc(char c) {
  while(!uart_istxready());
  IO_SET(base, UART_TXDATA, (int)c);
}

//rx functions
void uart_rxen(int val) {
  IO_SET(base, UART_RXEN, val);
}

void uart_rxwait() {
  while(!IO_GET(base, UART_RXREADY));
}

int uart_isrxready() {
  return (IO_GET(base, UART_RXREADY));
}

char uart_getc() {
  while(!uart_isrxready());
  return( (char) IO_GET(base, UART_RXDATA));
}

