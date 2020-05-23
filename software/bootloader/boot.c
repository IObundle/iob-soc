#include "system.h"
#include "interconnect.h"
#include "iob-uart.h"
#include "iob-cache.h"
#include "console.h"

#define BOOTRAM_BASE 2**BOOTROM_ADDR_W
#define BOOTCTR_BASE (1<<PBIT) |(BOOT_CTR<<(ADDR_W-N_SLAVES_W))

//#define DEBUG  // Uncomment this line for debug printfs

//memory pointer
#if RUN_DDR == 0 //SRAM
char *mem = (char *) (1<<BOOTROM_ADDR_W);
#else //DDR
char *mem = (char *) EXTRA_BASE;
#endif

unsigned int receiveFile() {

  // Send command
  uart_putc(STX);

  // Send Start to PC
  uart_putc(STR);
  
  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;
  
  // Write file to main memory
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }
  
  return file_size;
}

void sendFile(unsigned int file_size) {

  // Send command
  uart_putc(SRX);

  // Wait for PC
  while (uart_getc() != STR);
  
  // Write file size
  uart_putc((char)(file_size & 0x0ff));
  uart_putc((char)((file_size & 0x0ff00) >> 8));
  uart_putc((char)((file_size & 0x0ff0000) >> 16));
  uart_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // Read file from main memory
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
  cache_init(MEM_ADDR_W);
  while(!cache_buffer_empty());
#endif
    
  uart_puts("Program loaded\n");

#ifdef DEBUG
  // Send File
  uart_puts ("Sending program to UART...\n");
  
  sendFile(prog_size, 0);
  
  uart_puts("Program sent\n");
#endif

  uart_txwait();
  
  RAM_SET(int, BOOTCTR_BASE, 0);
}
