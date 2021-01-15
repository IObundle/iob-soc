#include "iob-uart.h"
#include <stdio.h>

//base address
static int base;
static int div_value;

//UART functions
void uart_init(int base_address, int div) {
  //capture base address for good
  base = base_address;
  div_value = div;
}

int uart_getdiv()
{
  return div_value;
}

void uart_txwait() {
  return;
}

int uart_txstatus(){
  return 1;
}

void uart_putc(char c) {
  putc(c, stdout);
}

void uart_rxwait(){
  return;
}

int uart_rxstatus(){
  return 1;
}

char uart_getc() {
  return ( (char) getc(stdin));
}

