#include <stdio.h>
#include "iob-uart.h"

//UART printing functions
void uart_puts(char *s) {
  while (*s) uart_putc(*s++);
  uart_putc(NUL);
}

void uart_printf(char* fmt, ...) {
  va_list args;
  char buffer[80] = {0};
  va_start(args, fmt);
  vsprintf (buffer, fmt, args);
  va_end(args);
  uart_puts(buffer);
  uart_txwait();
}

//UART basic functions
void uart_init(int base_address, int div) {
  //capture base address for good
  uart_setbaseaddr(base_address);
  
  //pulse soft reset
  uart_softrst(1);
  uart_softrst(0);

  //Set the division factor div
  //div should be equal to round (fclk/baudrate)
  //E.g for fclk = 100 Mhz for a baudrate of 115200 we should uart_setdiv(868)
  uart_setdiv(div);

  //enable TX and RX
  uart_txen(1);
  uart_rxen(1);
}

void uart_finish() {
  uart_putc(EOT);
  uart_txwait();
}

//Sends the name of the file to use
void uart_sendstr (char* name) {

  int i=0;
  while ( name[i] != NUL )
    uart_putc(name[i++]);

  uart_putc (NUL);

}

//Receives file into mem
int uart_recvfile(char* file_name, char **mem) {

  uart_printf ("%s: requesting to receive file %s\n", UART_PROGNAME, file_name);

  //send file receive request
  uart_putc (FRX);

  //send file name
  uart_sendstr(file_name);

  //receive file size
  int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;

  //allocate space for file if pointer not given
  if( mem[0] == (char *)(-1) )
    mem[0] = malloc(file_size);
  
  //write file to memory
  for (int i = 0; i < file_size; i++) {
    mem[0][i] = uart_getc();
  }

  uart_printf("%s: file received (%d bytes)\n", UART_PROGNAME, file_size);

  return file_size;
}

//Sends mem contents to a file
void uart_sendfile(char *file_name, int file_size, char *mem) {

  uart_printf("%s: requesting to send file %s\n", UART_PROGNAME, file_name);

  //send file transmit command
  uart_putc(FTX);
	
  //send file name
  uart_sendstr(file_name);
	
  // send file size
  uart_putc((char)(file_size & 0x0ff));
  uart_putc((char)((file_size & 0x0ff00) >> 8));
  uart_putc((char)((file_size & 0x0ff0000) >> 16));
  uart_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // send file contents
  for (int i = 0; i < file_size; i++)
    uart_putc(mem[i]);

  uart_printf("%s: file sent (%d bytes)\n",  UART_PROGNAME, file_size);
}



