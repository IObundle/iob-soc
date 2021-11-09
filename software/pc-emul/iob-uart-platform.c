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

//Receives file into mem
int uart_recvfile_pc(char* file_name, char **mem) {

  uart_puts(UART_PROGNAME);
  uart_puts (": requesting to receive file\n");

  // opening the file in read mode
  FILE* fp = fopen(file_name, "r");

  // checking if the file exist or not
  if (fp == NULL) {
      uart_puts(UART_PROGNAME);
      printf(": file %s not found\n", file_name);
      return -1;
  }

  // calculating the size of the file
  fseek(fp, 0L, SEEK_END);
  int file_size = ftell(fp);
  fseek(fp, 0, SEEK_SET);  /* same as rewind(f); */

  //allocate space for file if file pointer not initialized
  if((*mem) == NULL) {
    (*mem) = (char *) malloc(file_size);
    if ((*mem) == NULL) {
      uart_puts(UART_PROGNAME);
      uart_puts("Error: malloc failed");
    }
  }

  //write file to memory
  size_t read_n = fread((*mem), 1, file_size, fp);
  if (read_n != file_size) {
    uart_puts(UART_PROGNAME);
    uart_puts(": could not read entire file\n");
  }


  // closing the file
  fclose(fp);

  uart_puts(UART_PROGNAME);
  uart_puts(": file received\n");

  return file_size;
}

//Sends mem contents to a file
void uart_sendfile_pc(char *file_name, int file_size, char *mem) {

  uart_puts(UART_PROGNAME);
  uart_puts(": requesting to send file\n");

  // opening the file in read mode
  FILE* fp = fopen(file_name, "w");

  // checking if the file exist or not
  if (fp == NULL) {
      uart_puts(UART_PROGNAME);
      printf(": couldn't create file %s\n", file_name);
  }

  // write file contents
  fwrite(mem, 1, file_size, fp);

  // closing the file
  fclose(fp);

  uart_puts(UART_PROGNAME);
  uart_puts(": file sent\n");
}
