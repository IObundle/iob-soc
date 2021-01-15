#include "iob-uart.h"

void uart_puts(char *s) {
  while (*s) uart_putc(*s++);
}

//Loads file into mem
void uart_loadfw(char *mem) {

  uart_puts (PROGNAME);
  uart_puts (": Loading file...\n");
  uart_endtext(); //free host from text mode
  
  uart_startrecvfile();
  
	//Wait for PC ACK
  while (uart_getc() != ACK);	
	
  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;
  
  // Write file to memory
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }

  uart_starttext();
  uart_puts (PROGNAME);
  uart_puts(": File loaded\n");
  
}

void uart_connect() {
  char host_resp;

  do {
    uart_putc(ENQ);
    //    uart_sleep(1);
    host_resp = uart_getc();
  } while(host_resp != ACK);

  uart_starttext();
}

void uart_finish() {
	uart_endtext();
	uart_disconnect();
	uart_txwait();
}




