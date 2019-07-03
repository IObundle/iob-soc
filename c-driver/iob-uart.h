#include <stdlib.h>
#include <stdarg.h>

#define MEMSET(base, location, value) (*((volatile int*) (base + (sizeof(int)) * location)) = value)
#define MEMGET(base, location)        (*((volatile int*) (base + (sizeof(int)) * location)))

//Memory Map
#define UART_WAIT 0
#define UART_DIV 1
#define UART_DATAOUT 2
#define UART_RESET 3

//Functions

//Reset UART
void uart_init(int base_address, int div);

//Get the division factor div
int uart_getdiv();

//Wait for UART be ready to operate
void uart_wait();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(const char *s);

//formated print
void uart_printf(const char* fmt, ...);
