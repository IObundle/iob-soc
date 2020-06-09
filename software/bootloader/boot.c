#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"
#include "iob-cache.h"
#include "boot.h"

int main() {

  //init uart 
  uart_init(UART_BASE, UART_CLK_FREQ/UART_BAUD_RATE);

  //call host
  uart_connect();

  //greet host 
  uart_putc(STX);
  uart_puts ("\n\n\nIOb-SoC Bootloader\n");
  uart_puts ("------------------\n\n");
  uart_putc(ETX);
      
  unsigned int file_size;

  //enter command loop
  while (1) {
    char host_cmd = (char) uart_getc();
    switch(host_cmd) {
    case STX:
      file_size = uart_getfile(mem);
      uart_putc(STX);
      uart_printf("File received (%d bytes)\n", file_size);
      uart_putc(ETX);
      break;
    case ETX:
      //todo: receive file size
      uart_sendfile(file_size, mem);
      uart_putc(STX);
      uart_printf("File sent (%d bytes)\n", file_size);
      uart_putc(ETX);
      break;
    case EOT:
      uart_putc(STX);
      uart_puts ("Restarting CPU to run program...\n\n\n\n");
      uart_putc(ETX);
#if USE_DDR
      //wait for cache write buffer to empty  
      cache_init(DDR_ADDR_W);
      while(!cache_buffer_empty());
#endif
      RAM_SET(int, BOOTCTR_BASE, 2);//{cpu_rst_req=1, boot=0}
      break;
    default: break;
    }
  }
}
