/*********************************************************
 *                    Tester Firmware                    *
 *********************************************************/
#include "stdlib.h"
#include <stdio.h>
#include "system.h"
#include "tester_periphs.h"
#include "iob-uart.h"
#include "printf.h"
#include "iob_nativebridgeif_swreg.h"

int main()
{
  char c, msgBuffer[512], *sutStr;
  int i = 0;

  //Init uart0
  uart_init(UART0_BASE,FREQ/BAUD);   
  IOB_NATIVEBRIDGEIF_INIT_BASEADDR(IOBNATIVEBRIDGEIF0_BASE);

  uart_puts("\n\nHello from tester!\n\n\n");

  //Init and switch to uart1 (connected to the SUT)
  uart_init(UART1_BASE,FREQ/BAUD);   

  //Wait for ENQ signal from SUT
  while(uart_getc()!=ENQ);
  //Send ack to sut
  uart_putc(ACK);

  //Read and store messages sent from SUT
  while ((c=uart_getc())!=EOT){
    msgBuffer[i]=c;
    i++;
  }
  msgBuffer[i]=EOT;
  
  //End UART1 connection with SUT
  uart_finish();
  
  //Switch back to UART0
  IOB_UART_INIT_BASEADDR(UART0_BASE);
  
  //Send messages previously stored from SUT
  uart_puts("#### Messages received from SUT: ####\n\n");
  for(i=0; msgBuffer[i]!=EOT; i++){
    uart_putc(msgBuffer[i]);
  }
  uart_puts("\n#### End of messages received from SUT ####\n\n");

  //Read data from IOBNATIVEBRIDGEIF (was written by the SUT)
  uart_puts("REGFILEIF contents read by the Tester:\n");
  printf("%d \n", IOB_NATIVEBRIDGEIF_GET_REG3());
  printf("%d \n", IOB_NATIVEBRIDGEIF_GET_REG4());

#ifdef USE_DDR
#ifdef RUN_EXTMEM
  //Get address of first char in string stored in SUT's memory with first bit inverted
  sutStr=(char*)(IOB_NATIVEBRIDGEIF_GET_REG5() ^ (0b1 << (DCACHE_ADDR_W-1))); //Note, DCACHE_ADDR_W may not be the same as DDR_ADDR_W when running in fpga

  //Print the string by accessing that address
  uart_puts("\nString read by Tester directly from SUT's memory:\n");
  for(i=0; sutStr[i]!='\0'; i++){
    uart_putc(sutStr[i]);
  }
#else
  //Print the string by reading DDR memory starting at address 0.
  uart_puts("\nString read by Tester from DDR:\n");
  sutStr=(char*)(0b1 << E); //Address 0 of DDR
  for(i=0; sutStr[i]!='\0'; i++){
    uart_putc(sutStr[i]);
  }
#endif
#endif

  uart_putc('\n');

  //End UART0 connection
  uart_finish();
}
