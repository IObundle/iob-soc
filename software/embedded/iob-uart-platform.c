#include "interconnect.h"
#include "iob-uart.h"

//base address
static int base;

void uart_setbaseaddr(int v)
{
  base = v;
}

void uart_softrst(int v)
{
  IO_SET(base, UART_SOFTRESET, v);
}

void uart_setdiv(int div)
{
  IO_SET(base, UART_DIV, div);
}


//tx functions
void uart_txen(int v) {
  IO_SET(base, UART_TXEN, v);
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

void uart_putint(int i) {
  while(!uart_istxready());
  IO_SET(base, UART_TXDATA, i);
}

//rx functions
void uart_rxen(int v) {
  IO_SET(base, UART_RXEN, v);
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

int uart_getint() {
  while(!uart_isrxready());
  return IO_GET(base, UART_RXDATA);
}

