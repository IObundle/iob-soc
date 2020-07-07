#include "interconnect.h"
#include "iob-uart.h"

//base address
static int base;

//UART functions
void uart_init(int base_address, int div) {
  //capture base address for good
  base = base_address;

  //pulse soft reset 
  MEMSET(base, UART_SOFT_RESET, 1);
  MEMSET(base, UART_SOFT_RESET, 0);

  //Set the division factor div
  //div should be equal to round (fclk/baudrate)
  //E.g for fclk = 100 Mhz for a baudrate of 115200 we should uart_setdiv(868)
  MEMSET(base, UART_DIV, div);
  MEMSET(base, UART_RXEN, 1);
}

int uart_getdiv()
{
  return (MEMGET(base, UART_DIV));
}

//tx functions
void uart_txwait() {
  while(MEMGET(base, UART_WRITE_WAIT));
}

int uart_txstatus() {
  return (!MEMGET(base, UART_WRITE_WAIT));
}

inline void uart_putc(char c) {
  while(MEMGET(base, UART_WRITE_WAIT));
  MEMSET(base, UART_DATA, (int)c);
}


void uart_rxwait() {
  while(!MEMGET(base, UART_READ_VALID));
}

int uart_rxstatus() {
  return (MEMGET(base, UART_READ_VALID));
}

inline char uart_getc() {
  while(!MEMGET(base, UART_READ_VALID));
  return( (char) MEMGET(base, UART_DATA));
}

void uart_itoa(int value, char* str, int base){
  itoa(value, str, base);
}
