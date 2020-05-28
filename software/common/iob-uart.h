#include <stdlib.h>
#include <stdarg.h>

//Useful ASCII codes
#define STX 2
#define ETX 3
#define ENQ 5
#define ACK 6

//Memory Map
#define UART_WRITE_WAIT 0
#define UART_DIV        1
#define UART_DATA       2
#define UART_SOFT_RESET 3
#define UART_READ_VALID 4
#define UART_RXEN       5

//Functions

//Reset UART and set the division factor
void uart_init(int base_address, int div);

//Get the division factor div
int uart_getdiv();

//Wait for tx to be ready
void uart_txwait();

//Get tx status (0/1 = busy/ready)
int uart_txstatus();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(const char *s);

//formated print
void uart_printf(const char* fmt, ...);

//Send file
void uart_sendfile(unsigned int file_size, char *mem);

//Wait for rx to be ready
void uart_rxwait();

//Get rx status (0/1 = busy/ready)
int uart_rxstatus();

//Get char
char uart_getc();

//Get file 
unsigned int uart_getfile(char *mem);

#ifdef PCSIM
//itoa definition
void itoa(int value, char* str, int base);
#endif
