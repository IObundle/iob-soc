#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"

int main()
{
  //init uart
  uart_init(UART_BASE,FREQ/BAUD);

  //test puts
  uart_puts("\n\n\nHello world!\n\n\n");

  //test printf with floats 
  printf("Value of Pi = %f\n\n", 3.1415);

  //test file receive
  char *buf = malloc(10000);
  int file_size = 0;
  file_size = uart_recvfile("Makefile", &buf);

  uart_finish();
}
