#include "iob-uart.h"
#include <stdio.h>

//base address
static int base;
static int div_value;

//UART functions

void uart_setbaseaddr(int v)
{
  return;
}

void uart_softrst(int v)
{
  return;
}

int uart_getdiv()
{
  return div_value;
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
  if(c > 6) //6 = ACK ascii char
    putc(c, stdout);
}

//rx functions
void uart_rxen(int v) {
  return;
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

