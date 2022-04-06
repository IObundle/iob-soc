#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>

#include "iob-lib.h"
#include "iob_uart_swreg.h"
#include "iob-uart-platform.h"

#define UART_PROGNAME "IOb-UART"

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

//Reset UART and set the division factor
void uart_init(int base_address, uint16_t div);

//Close transmission
void uart_finish();

//Soft reset
void uart_softrst(uint8_t v);

//Set the division factor div (fclk/baud)
void uart_setdiv(uint16_t v);

//TX FUNCTIONS

//Enable / disable tx
void uart_txen(uint8_t val);

//Wait for tx to be ready
void uart_txwait();

//Get tx status (0/1 = busy/ready)
uint8_t uart_istxready();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(const char *s);

//Send file
void uart_sendfile(char* file_name, int file_size, char *mem);

//RX FUNCTIONS

//Enable / diable rx
void uart_rxen(uint8_t val);

//Wait for rx to be ready
void uart_rxwait();

//Get rx status (0/1 = busy/ready)
uint8_t uart_isrxready();

//Get char
char uart_getc();

//Receive file 
int uart_recvfile(char* file_name, char **mem);
