/*********************************************************
 *                    Tester Firmware                    *
 *********************************************************/
#include "stdlib.h"
#include <stdio.h>
#include "system.h"
#include "tester_periphs.h"
#include "iob-uart.h"
#include "printf.h"
//#include "iob-nativebridgeif.h"

int main()
{
  char c, msgBuffer[512];
  int i = 0;

  //Init uart0
  uart_init(UART0_BASE,FREQ/BAUD);   
  //nativebridgeif_setbaseaddr(NATIVEBRIDGEIF0_BASE);

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
  uart_setbaseaddr(UART0_BASE);
  
  //Send messages previously stored from SUT
  uart_puts("#### Messages received on Tester by UART from SUT: ####\n\n");
  for(i=0; msgBuffer[i]!=EOT; i++){
    uart_putc(msgBuffer[i]);
  }
  uart_puts("\n#### End of messages received on Tester by UART from SUT ####\n\n");

  //Read data from NATIVEBRIDGEIF (was written by the SUT)
  //uart_puts("REGFILEIF contents read by the Tester (contents written by the SUT; read using the Tester's NATIVEBRIDGEIF that is connected to SUT's REGFILEIF):\n");
  //printf("%d \n", nativebridgeif_readreg(2));
  //printf("%d \n", nativebridgeif_readreg(3));

  //End UART0 connection
  uart_finish();
}
