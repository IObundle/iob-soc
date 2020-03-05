#include "system.h"
#include "iob-uart.h"
#include "iob-cache.h"
#include "console.h"

//memory access macros
#define RAM_PUTCHAR(location, value) (*((char*) (location)) = value)
#define RAM_PUTINT(location, value) (*((int*) (location)) = value)


//peripheral addresses 
//memory
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

//#define DEBUG  // Uncomment this line for debug printfs

unsigned int receiveFile(void) {
  
  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;
  
  // Write file to main memory
  volatile char *mem = (volatile char *) MAIN_MEM;
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }
  
  return file_size;
}

void sendFile(unsigned int file_size, unsigned int offset) {
  
  // Write file size
  uart_putc((char)(file_size & 0x0ff));
  uart_putc((char)((file_size & 0x0ff00) >> 8));
  uart_putc((char)((file_size & 0x0ff0000) >> 16));
  uart_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // Read file from main memory
  volatile char *mem = (volatile char *) (MAIN_MEM + offset);
  for (unsigned int i = 0; i < file_size; i++) {
    uart_putc(mem[i]);
  }
  
  return;
}

int main() {
  
  // Start Communication
  uart_init(UART, UART_CLK_FREQ/UART_BAUD_RATE);
  
  // Request File
  uart_puts ("Loading program from UART...\n");
  uart_putc(STX);
  
  unsigned int prog_size = receiveFile();
  
  uart_printf("load_address=%x, prog_size=%d \n", MAIN_MEM, prog_size);
  
#ifdef DEBUG
  uart_puts("Printing program from Main Memory:\n");
  
  volatile int *memInt = (volatile int *) MAIN_MEM;
  for (unsigned int i = 0; i < prog_size/4; i++){
    uart_printf("%x\n", memInt[i]);
  }
  uart_puts("Finished printing the Main Memory program\n");
#endif
  
#ifdef USE_DDR
  while(!ctrl_buffer_empty(CACHE_CTRL));
#endif
  
  uart_puts("Program loaded\n");
  
  // Send File
  uart_puts ("Sending program to UART...\n");
  uart_putc(SRX);
  
  sendFile(prog_size, 0);
  
  uart_puts("Program sent\n");
  uart_txwait();
  
  RAM_PUTINT(SOFT_RESET, 0);
}
