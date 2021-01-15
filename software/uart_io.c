#include <stdio.h>
#include "iob-uart.h"

char buffer[80] = {0};

void uart_printf(char* fmt, ...) {
  va_list args;
  va_start(args, fmt);
  vsprintf (buffer, fmt, args);
  va_end(args);
  uart_puts(buffer);
  uart_txwait();
}
