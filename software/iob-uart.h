#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>

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

//UART commands
#define STX 2 //start text
#define ETX 3 //end text
#define EOT 4 //end of transission
#define ENQ 5 //enquiry
#define ACK 6 //acklowledge
#define FTX 7 //transmit file
#define FRX 8 //receive file


//UART functions

//Set base address
void uart_setbaseaddr(int v);

//Soft reset
void uart_softrst(int v);

//Reset UART and set the division factor
void uart_init(int base_address, int div);

//Close transmission
void uart_finish();

//Set the division factor div (fclk/baud)
void uart_setdiv(int v);

//Get char
char uart_getc();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(char *s);

//formated print
//void uart_printf(char* fmt, ...);

//Enable / diable tx
void uart_txen(int val);

//Wait for tx to be ready
void uart_txwait();

//Get tx status (0/1 = busy/ready)
int uart_istxready();

//Enable / diable rx
void uart_rxen(int val);

//Wait for rx to be ready
void uart_rxwait();

//Get rx status (0/1 = busy/ready)
int uart_isrxready();

//Loads firmware
void uart_loadfw(char *mem);

//Send file
void uart_sendfile(char* file_name, int file_size, char *mem);

//Receive file 
int uart_recvfile(char* file_name, char **mem);

