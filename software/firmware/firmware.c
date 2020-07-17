#include "system.h"
#include "periphs.h"

#include "iob-uart.h"

//wip: test large global vars
//int a[2000] = {0};

int main()
{ 
  //init uart 
  uart_init(UART_BASE,FREQ/BAUD);   
  uart_printf("\n\n\nHello world!\n\n\n");
}
