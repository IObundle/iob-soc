#include <stdint.h>
#include "iob-uart.h"

//base address
static int base;

void uart_setbaseaddr(int v)
{
  base = v;
}

void uart_softrst(uint8_t v)
{
    IO_SET(UART_SOFTRESET_TYPE, base, UART_SOFTRESET, v);
}

void uart_setdiv(uint16_t div)
{
    IO_SET(UART_DIV_TYPE, base, UART_DIV, div);
}

//TX FUNCTIONS
void uart_txen(uint8_t v) {
    IO_SET(UART_TXEN_TYPE, base, UART_TXEN, v);
}

void uart_txwait() {
    while(!IO_GET(UART_TXREADY_TYPE, base, UART_TXREADY));
}

uint8_t uart_istxready() {
    return IO_GET(UART_TXREADY_TYPE, base, UART_TXREADY);
}

void uart_putc(char c) {
    while(!uart_istxready());
    IO_SET(UART_TXDATA_TYPE, base, UART_TXDATA, c);
}

//RX FUNCTIONS
void uart_rxen(uint8_t v) {
    IO_SET(UART_RXEN_TYPE, base, UART_RXEN, v);
}

void uart_rxwait() {
    while(!IO_GET(UART_RXREADY_TYPE, base, UART_RXREADY));
}

uint8_t uart_isrxready() {
    return IO_GET(UART_RXREADY_TYPE, base, UART_RXREADY);
}

char uart_getc() {
    while(!uart_isrxready());
    return IO_GET(UART_RXDATA_TYPE, base, UART_RXDATA);
}

//UART basic functions
void uart_init(int base_address, uint16_t div) {
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

//Print string, excluding end of string (0)
void uart_puts(const char *s) {
  while (*s) uart_putc(*s++);
}

//Sends the name of the file to use, including end of string (0)
void uart_sendstr (char* name) {
  int i=0;
  do
    uart_putc(name[i]);
  while (name[i++]);
}

//Receives file into mem
int uart_recvfile(char* file_name, char **mem) {

  uart_puts(UART_PROGNAME);
  uart_puts (": requesting to receive file\n");

  //send file receive request
  uart_putc (FRX);

  //send file name
  uart_sendstr(file_name);


  //receive file size
  int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;

  //allocate space for file if file pointer not initialized
  if((*mem) == NULL) {
    (*mem) = (char *) malloc(file_size);
    if ((*mem) == NULL) {
      uart_puts(UART_PROGNAME);
      uart_puts("Error: malloc failed");
    }
  }

  //send ACK before receiving file
  uart_putc(ACK);

  //write file to memory
  for (int i = 0; i < file_size; i++) {
    (*mem)[i] = uart_getc();
  }

  uart_puts(UART_PROGNAME);
  uart_puts(": file received\n");

  return file_size;
}

//Sends mem contents to a file
void uart_sendfile(char *file_name, int file_size, char *mem) {

  uart_puts(UART_PROGNAME);
  uart_puts(": requesting to send file\n");

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

  uart_puts(UART_PROGNAME);
  uart_puts(": file sent\n");
}
