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

void uart_softrst(int v)
{
  div_value=0;
  return;
}

void uart_setdiv(int div)
{
  div_value = div;
  return;
}

//tx functions
void uart_txen(int v) {
  return;
}

void uart_txwait() {
  return;
}

int uart_istxready(){
  return 1;
}

void uart_putc(char c) {
  //send byte to console
}

//rx functions
void uart_rxen(int v) {
  return;
}

void uart_rxwait(){
  return;
}

int uart_rxisready(){
  return 1;
}

char uart_getc() {
  //get byte from console
}

