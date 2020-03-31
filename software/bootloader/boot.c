#include "system.h"
#include "iob-uart.h"
#include "iob-cache.h"
#include "console.h"

//memory access macros
#define RAM_PUTCHAR(location, value) (*((char*) (location)) = value)
#define RAM_PUTINT(location, value) (*((int*) (location)) = value)

//#define DEBUG  // Uncomment this line for debug printfs

unsigned int receiveFile(void) {
  
  // Send Start to PC
  uart_putc(STR);
  
  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;
  
  // Write file to main memory
  volatile char *mem = (volatile char *) 0;
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }
  
  return file_size;
}

void sendFile(unsigned int file_size, unsigned int offset) {
  
  // Wait for PC
  while (uart_getc() != STR);
  
  // Write file size
  uart_putc((char)(file_size & 0x0ff));
  uart_putc((char)((file_size & 0x0ff00) >> 8));
  uart_putc((char)((file_size & 0x0ff0000) >> 16));
  uart_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // Read file from main memory
  volatile char *mem = (volatile char *) offset;
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
  
  uart_printf("Program size=%d bytes\n", prog_size);
  
#ifdef DEBUG
  uart_puts("Printing program from Main Memory:\n");
  
  volatile int *memInt = (volatile int *) 0;
  for (unsigned int i = 0; i < prog_size/4; i++){
    uart_printf("%x\n", memInt[i]);
  }
  uart_puts("Finished printing the Main Memory program\n");
#endif
  
#ifdef USE_DDR
  cache_init(MAINRAM_ADDR_W);
  while(!cache_buffer_empty());
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
