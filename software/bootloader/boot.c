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

#define LOAD FRX
#define PROGNAME "IOb-Bootloader"
int main() {

  //init uart 
  uart_init(UART_BASE, FREQ/BAUD);

  //connect with host, comment to disable handshaking
  uart_connect();

  //start message
  uart_puts (PROGNAME);
  uart_puts (": started...\n");
  if(USE_DDR_SW){
    uart_puts (PROGNAME);
    uart_puts(": DDR in use\n");
  }
  if(RUN_DDR_SW){
    uart_puts (PROGNAME);
    uart_puts(": Program to run from DDR\n");
  }
  
  char host_cmd = uart_getc(); //receive command
  
  if (host_cmd==LOAD) //load firmware
      uart_loadfw(prog_start_addr);
 	//run firmware
  uart_puts (PROGNAME);
  uart_puts (": ");
  uart_puts ("Restart CPU to run user program...\n");
  uart_txwait();
#if (USE_DDR && RUN_DDR)
  //by reading any DDR data, it forces the caches to first write everyting before reason (write-through write-not-allocate)
  char force_cache_read = prog_start_addr[0];
#endif
  //reboot and run firmware (not bootloader)
  MEM_SET(int, BOOTCTR_BASE, 0b10);//{cpu_rst_req=1, boot=0}
  
}
