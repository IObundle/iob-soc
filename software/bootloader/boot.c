#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"
#include "iob-cache.h"

// address to copy firmware to
#if (USE_DDR==0 || (USE_DDR==1 && RUN_DDR==0))
char *mem = (char *) (1<<BOOTROM_ADDR_W);
#else
char *mem = (char *) EXTRA_BASE;
#endif


int main() {

  //init uart 
  uart_init(UART_BASE, UART_CLK_FREQ/UART_BAUD_RATE);

  //call host
  uart_connect();
  
  //greet host 
  uart_starttext();
  uart_puts ("\n\n\nIOb-SoC Bootloader\n");
  uart_puts ("------------------\n\n");
  uart_endtext();
      
  unsigned int file_size;

  //enter command loop
  while (1) {
    char host_cmd = uart_getcmd(); //receive command
    switch(host_cmd) {
    case STX: //load firmware
      file_size = uart_getfile(mem);
      uart_starttext();
      uart_printf("File received (%d bytes)\n", file_size);
      uart_endtext();
      break;
    case ETX: //return firmware to host
      //todo: receive file address and size
      uart_sendfile(file_size, mem);
      uart_starttext();
      uart_printf("File sent (%d bytes)\n", file_size);
      uart_endtext();
      break;
    default: break;
    case EOT: //run firmware
      uart_starttext();
      uart_puts ("Rebooting CPU to run program...\n\n\n\n");
      uart_endtext();
#if USE_DDR
      //wait for cache write buffer to empty  
      cache_init(FIRM_ADDR_W);
      while(!cache_buffer_empty());
#endif
      //reboot and run 
      RAM_SET(int, BOOTCTR_BASE, 2);//{cpu_rst_req=1, boot=0}
      break;
    }
  }
}
