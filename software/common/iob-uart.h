#include <stdlib.h>
#include <stdarg.h>

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

//Print char
void uart_putc(char c);

//Print string
void uart_puts(const char *s);

//formated print
void uart_printf(const char* fmt, ...);

//Getchar
char uart_getc();

#ifdef PCSIM
//itoa definition
void itoa(int value, char* str, int base);
#endif
