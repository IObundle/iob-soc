#include "iob-uart.h"

void uart_puts(char *s) {
  while (*s) uart_putc(*s++);
}

//Loads file into mem
void uart_loadfw(char *mem) {

  //uart_puts (UART_PROGNAME);
  //uart_puts (": Loading file...\n");

  //request file 
  //uart_putc(`FRX);              

  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;

  // Write file to memory
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }

  uart_puts (UART_PROGNAME);
  uart_puts(": File loaded\n");
  
}

void uart_finish() {
  uart_putc(EOT);
  uart_txwait();
}




