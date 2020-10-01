#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"

#if (USE_DDR==1 && RUN_DDR==1)
#include "iob-cache.h"
#endif

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


#define PROGNAME "IOb-Bootloader"

int main() {

  //init uart 
  uart_init(UART_BASE, FREQ/BAUD);

  //connect with host, comment to disable handshaking
  uart_connect();

  //welcome message
  uart_printf ("%s: USE_DDR=%d RUN_DDR=%d\n", PROGNAME, USE_DDR_SW, RUN_DDR_SW);

  unsigned int file_size;
  //enter command loop
  while (1) {
    char host_cmd = uart_getc(); //receive command
    switch(host_cmd) {
    case LOAD: //load firmware
      file_size = uart_getfile(prog_start_addr);
      break;
    case SEND: //return firmware to host
      uart_sendfile(file_size, prog_start_addr);
      break;
    case RUN: //run firmware
      uart_printf ("%s: Reboot CPU and run program...\n", PROGNAME);
#if (USE_DDR && RUN_DDR)
      //by reading any DDR data, it forces the caches to first write everyting before reason (write-through write-not-allocate)
      char force_cache_read = prog_start_addr[0];
#endif
      //reboot and run firmware (not bootloader)
      MEM_SET(int, BOOTCTR_BASE, 0b10);//{cpu_rst_req=1, boot=0}
      break;
    default: ;
    }
  }
}
