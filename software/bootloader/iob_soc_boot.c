#include "bsp.h"
#include "iob-uart.h"
#include "iob_soc_conf.h"
#include "iob_soc_periphs.h"

#ifdef USE_EXTMEM
#include "iob-cache.h"
#endif

#define PROGNAME "IOb-Bootloader"

int main() {

  // init uart
  uart_init(UART0_BASE, FREQ / BAUD);

  // connect with console
  do {
    if (IOB_UART_GET_TXREADY())
      uart_putc((char)ENQ);
  } while (!IOB_UART_GET_RXREADY());

  // welcome message
  uart_puts(PROGNAME);
  uart_puts(": connected!\n");

#ifdef USE_EXTMEM
  uart_puts(PROGNAME);
  uart_puts(": System is using external memory\n");
#endif

  // sync with console
  while (uart_getc() != ACK) {
    uart_puts(PROGNAME);
    uart_puts(": Waiting for Console ACK.\n");
  }

  // address to copy firmware to
  char *prog_start_addr = (char *)(1 << 31);

#ifndef INIT_MEM
  // receive firmware from host
  int file_size = 0;
  char r_fw[] = "iob_soc_firmware.bin";
  file_size = uart_recvfile(r_fw, prog_start_addr);
  uart_puts(PROGNAME);
  uart_puts(": Loading firmware...\n");

  if (file_size == 0) {
    uart_puts(PROGNAME);
    uart_puts(": Error, file size is 0.\n");
  }
#endif

  // run firmware
  uart_puts(PROGNAME);
  uart_puts(": Reset CPU to run user program...\n");
  uart_txwait();

#ifdef USE_EXTMEM
  while (!cache_wtb_empty())
    ;
#endif
}
