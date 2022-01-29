#include "stdlib.h"
#include <stdio.h>
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"
#ifdef REGFILEIF_TESTER_BASE
#include "iob-regfileif.h"
#endif

int main()
{
  //init uart
  uart_init(UART0_BASE,FREQ/BAUD);   
  uart_puts("\n\n\nHello world!\n\n\n");

  //run REGFILEIF tests if the system was built with it (and the Tester)
  #ifdef REGFILEIF_TESTER_BASE
  regfileif_setbaseaddr(REGFILEIF_TESTER_BASE);   

  regfileif_writereg(0, 666);
  regfileif_writereg(1, 667);
  regfileif_writereg(2, 668);
  regfileif_writereg(3, 669);

  printf("%d \n", regfileif_readreg(0));
  printf("%d \n", regfileif_readreg(1));
  printf("%d \n", regfileif_readreg(2));
  printf("%d \n", regfileif_readreg(3));
  #endif

  uart_finish();
}
