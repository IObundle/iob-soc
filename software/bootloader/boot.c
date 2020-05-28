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

  //sync with host
  do uart_putc(ENQ);
  while(uart_getc() != ACK);
    
  uart_puts ("\nIObundle Bootloader\n\n");

  uart_putc (ETX);

  //receive program
  unsigned int prog_size = uart_getfile(mem);

  uart_printf("Program received from host (%d bytes)\n", prog_size);
  
#ifdef USE_DDR
  //wait for cache write buffer to empty
  cache_init(FIRM_ADDR_W);
  while(!cache_buffer_empty());
#endif

  uart_puts ("Sending program back to host...\n");

  uart_putc (ETX);

  uart_sendfile(prog_size, mem);
  
  RAM_SET(int, BOOTCTR_BASE, 0);
}
