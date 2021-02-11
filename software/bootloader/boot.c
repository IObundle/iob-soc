#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"

#if (USE_DDR_SW==1 && RUN_DDR_SW==1)
#include "iob-cache.h"
#endif

#define UART_BASE (1<<P) |(UART<<(ADDR_W-2-N_SLAVES_W))
//why not include periphs.h instead?

#define PROGNAME "IOb-Bootloader"

int main() {

  //init uart 
  uart_init(UART_BASE, FREQ/BAUD);

  //connect with console
   do {
    if(uart_istxready())
      uart_putc(ENQ);
  } while(!uart_isrxready());

  //welcome message
  uart_puts (PROGNAME);
  uart_puts (": connected!\n");

  if(USE_DDR_SW){
    uart_puts (PROGNAME);
    uart_puts(": DDR in use\n");
  }
  if(RUN_DDR_SW){
    uart_puts (PROGNAME);
    uart_puts(": program to run from DDR\n");
  }

  // address to copy firmware to
  char **prog_start_addr;
  if (USE_DDR_SW==0 || (USE_DDR_SW==1 && RUN_DDR_SW==0))	
    *prog_start_addr = (char *) (1<<BOOTROM_ADDR_W);
  else
    *prog_start_addr = (char *) EXTRA_BASE;

  //receive firmware from host 
  int file_size = 0;
  if (uart_getc() == FRX) {//load firmware
    file_size = uart_recvfile("firmware.bin", prog_start_addr);
    uart_puts (PROGNAME);
    uart_puts (": Loading firmware...\n");
  }

  //sending firmware back for debug
  if(file_size) {
    uart_putc(FTX);
    uart_sendfile("fw_bin", file_size, *prog_start_addr);
  }
  
  //run firmware
  uart_puts (PROGNAME);
  uart_puts (": Restart CPU to run user program...\n");
  uart_txwait();

#if (USE_DDR && RUN_DDR)
  //by reading any DDR data, it forces the caches to first write everyting before reason (write-through write-not-allocate)
  char force_cache_read = prog_start_addr[0];
#endif
  //reboot and run firmware (not bootloader)
  MEM_SET(int, BOOTCTR_BASE, 0b10);//{cpu_rst_req=1, boot=0}
  
}
