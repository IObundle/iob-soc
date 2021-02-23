#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"

#if (USE_DDR_SW==1 && RUN_DDR_SW==1)
#include "iob-cache.h"
#endif

//defined here (and not in periphs.h) because it is the only peripheral used
//by the bootloader
#define UART_BASE (1<<P) |(UART<<(ADDR_W-2-N_SLAVES_W))

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
  char *prog_start_addr[1];
  if (USE_DDR_SW==0 || (USE_DDR_SW==1 && RUN_DDR_SW==0))	
    prog_start_addr[0] = (char *) (1<<BOOTROM_ADDR_W);
  else
    prog_start_addr[0] = (char *) EXTRA_BASE;

  //receive firmware from host 
  int file_size = 0;
  char r_fw[] = "firmware.bin";
  if (uart_getc() == FRX) {//file receive: load firmware
    file_size = uart_recvfile(r_fw, prog_start_addr);
    uart_puts (PROGNAME);
    uart_puts (": Loading firmware...\n");
  }

  //sending firmware back for debug
  char s_fw[] = "s_fw.bin";

  if(file_size)
    uart_sendfile(s_fw, file_size, prog_start_addr[0]);
  
  //run firmware
  uart_puts (PROGNAME);
  uart_puts (": Restart CPU to run user program...\n");
  uart_txwait();

#if (USE_DDR && RUN_DDR)
  //by reading any DDR data, it forces the caches to first write everyting before reason (write-through write-not-allocate)
  char force_cache_read = *prog_start_addr[0];
  uart_rxen(force_cache_read);//this line prevents compiler from optimizing away force_cache_read
#endif
  //reboot and run firmware (not bootloader)
  MEM_SET(int, BOOTCTR_BASE, 0b10);//{cpu_rst_req=1, boot=0}
  
}
