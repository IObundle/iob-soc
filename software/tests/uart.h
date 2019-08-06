#include <stdlib.h>
#include <stdarg.h>

//Memory access macros
#define MEMSET(base, location, value) (*((volatile int*) (base + (sizeof(int)) * location)) = value)
#define MEMGET(base, location)        (*((volatile int*) (base + (sizeof(int)) * location)))

//Memory Map
#define UART_WRITE_WAIT 0
#define UART_DIV        1
#define UART_DATA       2
#define UART_SOFT_RESET 3
#define UART_READ_VALID 4

//Uart functions
void uart_init(int base_address, int div);
void uart_printf(const char* fmt, ...);
int uart_get_read_valid();
void uart_read_wait();
int uart_getc();
