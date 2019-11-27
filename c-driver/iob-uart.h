#include <stdlib.h>
#include <stdarg.h>

#define MEMSET(base, location, value) (*((volatile int*) (base + (sizeof(int)) * location)) = value)
#define MEMGET(base, location)        (*((volatile int*) (base + (sizeof(int)) * location)))

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

//Get the write wait bit
//int uart_get_write_wait();

//Wait for UART be ready to operate
//void uart_write_wait();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(const char *s);

//formated print
void uart_printf(const char* fmt, ...);

//Get read valid
//int uart_get_read_valid();

//Wait for UART to be ready to read
//void uart_read_wait();

//Getchar
int uart_getc();
