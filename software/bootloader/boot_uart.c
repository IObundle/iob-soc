#include "system.h"
#include "iob-uart.h"

#define UART (UART_BASE<<(DATA_W-N_SLAVES_W))

volatile int* MAIN_MEM;
volatile int* SOFT_RESET;

volatile int* DATA_MEM;

int main()
{ 
  int counter, i = 0, j = 1;
  unsigned char temp;
  int line=0;
  int errors=0;

#ifdef USE_RAM
  MAIN_MEM = (volatile int*) (RAM_BASE<<(DATA_W-N_SLAVES_W));
#else
  MAIN_MEM = (volatile int*) (CACHE_BASE<<(DATA_W-N_SLAVES_W));
#endif

  uart_init(UART,UART_CLK_FREQ/UART_BAUD_RATE);

  uart_puts ("Load Program through UART to Main Memory...\n");
  uart_printf("load_address=%x, prog_size=%d \n", MAIN_MEM, PROG_SIZE);

  for (i = 0 ; i < (4*PROG_SIZE); i ++){
    line = 0;
    for (counter = 3; counter >= 0 ; counter--) {
      //read the byte to a char and append it to the line
      temp = uart_getc();
      line+=temp << (8*counter); //number of shitfs = number of bits in a byte
    }
     uart_printf("load_byte=%x\n", i);

    MAIN_MEM[i] = line;
  }

  uart_puts("\nProgram copy completed... Printing final copy:\n");
  for (i = 0 ; i < PROG_SIZE; i++){
    uart_printf("%x: ", i);//printing int instead of byte address
    uart_printf("%x\n", MAIN_MEM[i]);
  }

  uart_puts("\n\n******** MEM TEST *******\n\n");
  DATA_MEM = (volatile int *) (MAIN_MEM+PROG_SIZE/2);
  //uart_printf("Writing array to address: %x\n", DATA_MEM);

  //write data 
  for(i=0; i< PROG_SIZE/2;i++)
    DATA_MEM[i] = i;

  //read back 
  for(i=0;i< PROG_SIZE/2; i++)
    if(DATA_MEM[i] != i) {
      //uart_printf("fail: %x\n", i);
      errors++;
    }

  //exit on memory errors
  if(errors != 0) {
    //uart_printf("Test failed");
    return 1;
  }


  uart_puts("\nRestart ro run Main Memory program...\n");    

  *((volatile int*) SOFT_RESET) = 1;
}
