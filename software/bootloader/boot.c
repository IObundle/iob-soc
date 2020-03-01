#include "system.h"
#include "iob-uart.h"
#include "iob-cache.h"

//memory access macros
#define RAM_PUTCHAR(location, value) (*((char*) (location)) = value)
#define RAM_PUTINT(location, value) (*((int*) (location)) = value)

//peripheral addresses 

//main memory (where to copy firmware to)

#ifdef USE_DDR
#define MAIN_MEM (CACHE_BASE<<(ADDR_W-N_SLAVES_W))
#else
#define MAIN_MEM (MAINRAM_BASE<<(ADDR_W-N_SLAVES_W))
#endif

//uart
#define UART (UART_BASE<<(ADDR_W-N_SLAVES_W))
//soft reset
#define SOFT_RESET (SOFT_RESET_BASE<<(ADDR_W-N_SLAVES_W))
//cache controller
#define CACHE_CTRL (CACHE_CTRL_BASE<<(ADDR_W-N_SLAVES_W))

//debugging purposes
volatile int* MAIN_MEM_PROG;

int main()
{ 
  uart_init(UART, UART_CLK_FREQ/UART_BAUD_RATE);
  uart_printf ("Loading %d-byte program from UART...\n", PROG_SIZE);

  //write program to main memory
  for (int i=0 ; i < PROG_SIZE; i++) {
    char c = uart_getc();
    RAM_PUTCHAR(MAIN_MEM+i, c);
  }

  //wait for write through buffer to empty
#ifdef USE_DDR
  while(!ctrl_buffer_empty(CACHE_CTRL));
#endif

  uart_puts("Program loaded\n");
  uart_txwait();
  
  
  RAM_PUTINT(SOFT_RESET, 0);
}
