#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"
#include "iob-cache.h"

//memory pointer
#if RUN_DDR == 0 //SRAM
char *mem = (char *) (1<<BOOTROM_ADDR_W);
#else //DDR
char *mem = (char *) EXTRA_BASE;
#endif

int main() {

  //init uart 
  uart_init(UART_BASE, UART_CLK_FREQ/UART_BAUD_RATE);

  //connect with host
  char host_resp;
  do {
    uart_putc(ENQ);
    host_resp = uart_getc();
  } while( host_resp != ACK && host_resp != EOT);

  if(host_resp == EOT) {
    uart_puts ("\n\n\nConnection closed by host. Bye!\n");
    return 0;
  }
  uart_puts ("\n\n\nIOb-SoC bootloader\n");
  uart_puts ("------------------\n\n");
  uart_puts ("Connected with host, waiting program...\n\n");


  //receive program
  uart_putc (ETX); //signal host
  unsigned int prog_size = uart_getfile(mem);
  uart_printf("Program received and loaded. (%d bytes)\n", prog_size);
  
#if USE_DDR
  //wait for cache write buffer to empty  
  uart_printf("Cache init\n");
  cache_init(FIRM_ADDR_W);
  uart_printf("Cache buffer empty?\n");
  while(!cache_buffer_empty());
  uart_printf("Cache buffer empty!\n");
#endif

  /*
  uart_puts ("Sending program back to host...\n");
  uart_putc (ETX);
  uart_sendfile(prog_size, mem);
  */
  uart_puts ("Restarting CPU to run program...\n\n\n\n"); 
  RAM_SET(int, BOOTCTR_BASE, 2);//{cpu_rst_req=1, boot=0}
}
