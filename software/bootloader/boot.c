#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"
#include "iob-cache.h"

#define UART_BASE (1<<P) |(UART<<(ADDR_W-2-N_SLAVES_W))

// address to copy firmware to
#if (USE_DDR==0 || (USE_DDR==1 && RUN_DDR==0))
char *prog_start_addr = (char *) (1<<BOOTROM_ADDR_W);
#else
char *prog_start_addr = (char *) EXTRA_BASE;
#endif

#define LOAD STX
#define SEND ETX
#define RUN  EOT

int main() {

  //init uart 
  uart_init(UART_BASE, FREQ/BAUD);

  //connect with host, comment to disable handshaking
  uart_connect();

  //welcome message
  uart_puts ("\n\n\nIOb-SoC Bootloader:\n\n");

  unsigned int file_size;
  //enter command loop
  while (1) {
    char host_cmd = uart_getcmd(); //receive command
    switch(host_cmd) {
    case LOAD: //load firmware
      file_size = uart_getfile(prog_start_addr);
      break;
    case SEND: //return firmware to host
      uart_sendfile(file_size, prog_start_addr);
      break;
    default: break;
    case RUN: //run firmware
      uart_puts ("Reboot CPU and run program...\n");
#if USE_DDR
      //wait for cache write buffer to empty  
      cache_init(FIRM_ADDR_W);
      while(!cache_buffer_empty());
#endif
      //reboot and run firmware
      MEM_SET(int, BOOTCTR_BASE, 2);//{cpu_rst_req=1, boot=0}
      break;
    }
  }
}
