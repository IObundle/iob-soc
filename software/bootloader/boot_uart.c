#include "system.h"
#include "iob-uart.h"

//memory access macros
#define RAM_PUTCHAR(location, value) (*((char*) (location)) = value)
#define RAM_PUTINT(location, value) (*((int*) (location)) = value)

//peripheral addresses 
//memory
#ifdef USE_RAM
#define MAIN_MEM (RAM_BASE<<(ADDR_W-N_SLAVES_W))
#else
#define MAIN_MEM (CACHE_BASE<<(ADDR_W-N_SLAVES_W))
#endif
//uart
#define UART (UART_BASE<<(ADDR_W-N_SLAVES_W))
//soft reset
#define SOFT_RESET (SOFT_RESET_BASE<<(ADDR_W-N_SLAVES_W))

//program size
//#define PROG_SIZE (1<<(RAM_ADDR_W-2))


int main()
{ 
#ifdef USE_DDR
  return 0;
#endif
  
  uart_init(UART, UART_CLK_FREQ/UART_BAUD_RATE);
  uart_puts ("Loading program from UART...\n");
  uart_printf("load_address=%x, prog_size=%d \n", MAIN_MEM, PROG_SIZE);

  for (int i=0 ; i < PROG_SIZE; i++) {
    //uart_printf("a %d\n", i);
    char c = uart_getc();
    //uart_printf("b %d\n", i);
    RAM_PUTCHAR(MAIN_MEM+i, c);
    //uart_printf("c %d\n", i);
  }
  
  uart_puts("Program loaded \n");
  uart_txwait();

  RAM_PUTINT(SOFT_RESET, 1);
  
}
