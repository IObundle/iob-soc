#include <stdint.h>
#include "iob-uart.h"
#include "iob_uart_swreg.h"

//base address
static int base;

void uart_setbaseaddr(int v)
{
  base = v;
}

void uart_softrst(uint8_t v)
{
  volatile uint8_t *addr = (uint8_t *) (base + UART_SOFTRESET);
  *addr= v;
}

void uart_setdiv(uint16_t div)
{
  volatile uint16_t *addr = (uint16_t *) (base + UART_DIV);
  *addr = div;
}

//TX FUNCTIONS
void uart_txen(uint8_t v) {
  volatile uint8_t *addr = (uint8_t *) (base+UART_TXEN);
  *addr = v;
}

void uart_txwait() {
  volatile uint8_t *addr = (uint8_t *) (base+UART_TXREADY);
  while(! *addr);
}

uint8_t uart_istxready() {
  volatile uint8_t *addr = (uint8_t *) (base+UART_TXREADY);
  uint8_t v = *addr;
  return v;
}

void uart_putc(char c) {
  while(!uart_istxready());
  volatile char *addr = (char *) (base+UART_TXDATA);
  *addr = c;
}

//RX FUNCTIONS
void uart_rxen(uint8_t v) {
  volatile uint8_t *addr = (uint8_t *) (base+UART_RXEN);
  *addr = v;
}

void uart_rxwait() {
  volatile uint8_t *addr = (uint8_t *) (base + UART_RXREADY);
  while(! *addr);
}

uint8_t uart_isrxready() {
  volatile uint8_t *addr = (uint8_t *) (base+UART_RXREADY);
  return *addr;
}

char uart_getc() {
  while(!uart_isrxready());
  volatile char *addr = (char *)(base+UART_RXDATA);
  return *addr;
}



