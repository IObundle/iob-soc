#include "system.h"
#include "iob-uart.h"

//memory access macros
#define RAMSET(location, value) (*((int*) (location)) = value)
#define RAMGET(location)        (*((int*) (location)))

//memory select
#ifdef USE_RAM
#define MAIN_MEM (RAM_BASE<<(ADDR_W-N_SLAVES_W))
#else
#define MAIN_MEM (CACHE_BASE<<(ADDR_W-N_SLAVES_W))
#endif

//peripheral addresses 
#define UART (UART_BASE<<(ADDR_W-N_SLAVES_W))
#define SOFT_RESET (SOFT_RESET_BASE<<(ADDR_W-N_SLAVES_W))

int main()
{ 
  int counter, i = 0, j = 1;
  unsigned char temp;
  int line;
  int errors=0;

#ifdef USE_DDR
  return 0;
#endif
  
  uart_init(UART,UART_CLK_FREQ/UART_BAUD_RATE);
  uart_puts ("Loading program from UART...\n");
  uart_printf("load_address=%x, prog_size=%d \n", MAIN_MEM, PROG_SIZE);

  for (i = 0 ; i < PROG_SIZE; i++) {
    line = 0;
    for (counter = 3; counter >= 0 ; counter--) {
      //read the byte to a char and append it to the line
      temp = uart_getc();
      line += (temp << (8*counter)); //number of shitfs = number of bits in a byte
    }
    RAMSET(MAIN_MEM + i*sizeof(int), line);
  }

  uart_puts("Program loaded \n");

  return 0;
  
}
