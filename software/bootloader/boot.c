#include "system.h"
#include "iob-uart.h"

#ifdef RUN_EXTMEM
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
    if(IOB_UART_GET_TXREADY())
      uart_putc((char) ENQ);
  } while(!IOB_UART_GET_RXREADY());

  //welcome message
  uart_puts (PROGNAME);
  uart_puts (": connected!\n");

#ifdef USE_DDR
    uart_puts (PROGNAME);
    uart_puts(": DDR in use\n");
#endif
    
#ifdef RUN_EXTMEM
    uart_puts (PROGNAME);
    uart_puts(": program to run from DDR\n");
#endif

  // address to copy firmware to
  char *prog_start_addr;
#ifdef RUN_EXTMEM
    prog_start_addr = (char *) EXTRA_BASE;
#else
    prog_start_addr = (char *) (1<<BOOTROM_ADDR_W);
#endif

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
    uart_sendfile(s_fw, file_size, prog_start_addr);
  
  //run firmware
  uart_puts (PROGNAME);
  uart_puts (": Restart CPU to run user program...\n");
  uart_txwait();

#ifdef RUN_EXTMEM
  while( !cache_wtb_empty() );
#endif

}
