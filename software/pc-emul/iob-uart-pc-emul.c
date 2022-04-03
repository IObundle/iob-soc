#include "iob-uart.h"
#include <stdio.h>

//base address
static int base;
static int div_value;

//UART functions

void uart_setbaseaddr(int v)
{
  //manage files to communicate with console here
  return;
}

void uart_softrst(uint8_t v)
{
  div_value=0;
  return;
}

void uart_setdiv(uint16_t div)
{
  div_value = div;
  return;
}

//tx functions
void uart_txen(uint8_t v) {
  return;
}

void uart_txwait() {
  return;
}

uint8_t uart_istxready(){
  return 1;
}

void uart_putc(char c) {
  //should send byte to console
  //temporary solution:
  putchar(c);
}

//rx functions
void uart_rxen(uint8_t v) {
  return;
}

void uart_rxwait(){
  return;
}

uint8_t uart_rxisready(){
  return 1;
}

char uart_getc() {
  //get byte from console
}

