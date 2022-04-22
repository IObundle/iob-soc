#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>

#include "iob_axistream_in_swreg.h"

#define AXISTREAMIN_PROGNAME "IOb-AXISTREAMIN"

//AXISTREAMIN commands
#define STX 2 //start text
#define ETX 3 //end text
#define EOT 4 //end of transission
#define ENQ 5 //enquiry
#define ACK 6 //acklowledge
#define FTX 7 //transmit file
#define FRX 8 //receive file


//AXISTREAMIN functions

//Reset AXISTREAMIN and set the division factor
void axistream_in_init(int base_address, uint16_t div);

//Close transmission
void axistream_in_finish();

//TX FUNCTIONS

//Enable / disable tx
void axistream_in_txen(uint8_t val);

//Wait for tx to be ready
void axistream_in_txwait();

//Print char
void axistream_in_putc(char c);

//Print string
void axistream_in_puts(const char *s);

//Send file
void axistream_in_sendfile(char* file_name, int file_size, char *mem);

//RX FUNCTIONS

//Wait for rx to be ready
void axistream_in_rxwait();

//Get char
char axistream_in_getc();

//Receive file 
int axistream_in_recvfile(char* file_name, char **mem);
