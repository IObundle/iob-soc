#include "stdlib.h"
#include <stdio.h>
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"
#include "iob-regfileif.h"

int main()
{
  //init uart
  uart_init(UART0_BASE,FREQ/BAUD);   
  regfileif_setbaseaddr(REGFILEIF_TESTER_BASE);   
  uart_puts("\n\n\nHello world!\n\n\n");

  regfileif_writereg(0, 666);
  regfileif_writereg(1, 667);
  regfileif_writereg(2, 668);
  regfileif_writereg(3, 669);

  printf("%d \n", regfileif_readreg(0));
  printf("%d \n", regfileif_readreg(1));
  printf("%d \n", regfileif_readreg(2));
  printf("%d \n", regfileif_readreg(3));

  uart_finish();
}
