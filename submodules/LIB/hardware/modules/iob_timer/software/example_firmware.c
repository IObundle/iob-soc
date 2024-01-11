#include "bsp.h"
#include "iob-timer.h"
#include "iob-uart.h"
#include "periphs.h"
#include "printf.h"
#include "system.h"

int main() {
  unsigned long long elapsed;
  unsigned int elapsedu;

  // init timer and uart
  timer_init(TIMER0_BASE);
  uart_init(UART_BASE, FREQ / BAUD);

  printf("\nHello world!\n");

  // read current timer count, compute elapsed time
  elapsed = timer_get_count();
  elapsedu = elapsed / (FREQ / 1000000);

  printf("\nExecution time: %d clock cycles\n", (unsigned int)elapsed);
  printf("\nExecution time: %dus @%dMHz\n\n", elapsedu, FREQ / 1000000);

  uart_finish();
}
