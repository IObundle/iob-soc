#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>
#include "iob-uart-ascii.h"

#define UART_PROGNAME "IOb-UART"

//Memory Map
#define UART_SOFTRESET 0
#define UART_DIV 1
#define UART_TXDATA 2
#define UART_TXEN 3
#define UART_TXREADY 4
#define UART_RXDATA 5
#define UART_RXEN 6
#define UART_RXREADY 7

//Functions

//Reset UART and set the division factor
void uart_init(int base_address, int div);

//Get the division factor div
int uart_getdiv();

//Get char
char uart_getc();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(char *s);

//formated print
void uart_printf(char* fmt, ...);

//Get tx status (0/1 = busy/ready)
int uart_istxready();

//Get rx status (0/1 = busy/ready)
int uart_isrxready();

//Wait for tx to be ready
void uart_txwait();

//Wait for rx to be ready
void uart_rxwait();

//Loads firmware
void uart_loadfw(char *mem);

//Send file
void uart_sendfile(unsigned int file_size, char* file_name, char *mem);

//Get file 
void uart_getfile(char* file_name, char *mem);

void uart_finish();

#define uart_startsendfile() uart_putc (FTX)

#define uart_startrecvfile() uart_putc (FRX)

#define uart_getcmd() uart_getc()

void uart_sleep (int n);
