/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include "bsp.h"
#include "iob_nco.h"
#include "iob_uart.h"
#include "periphs.h"
#include "printf.h"
#include "system.h"

int main() {
  unsigned long long elapsed;
  unsigned int elapsedu;

  // init nco and uart
  nco_init(NCO0_BASE);
  uart_init(UART_BASE, FREQ / BAUD);

  printf("\nHello world!\n");

  // read current nco count, compute elapsed time
  elapsed = nco_get_count();
  elapsedu = elapsed / (FREQ / 1000000);

  printf("\nExecution time: %d clock cycles\n", (unsigned int)elapsed);
  printf("\nExecution time: %dus @%dMHz\n\n", elapsedu, FREQ / 1000000);

  uart_finish();
}
