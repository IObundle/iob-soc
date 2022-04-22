#include <stdint.h>
#include "iob-axistream-in.h"

//TX FUNCTIONS
void axistream_in_txwait() {
    while(!AXISTREAMIN_GET_TXREADY());
}

void axistream_in_putc(char c) {
    while(!AXISTREAMIN_GET_TXREADY());
    AXISTREAMIN_SET_TXDATA(c);
}

//RX FUNCTIONS
void axistream_in_rxwait() {
    while(!AXISTREAMIN_GET_RXREADY());
}

char axistream_in_getc() {
    while(!AXISTREAMIN_GET_RXREADY());
    return AXISTREAMIN_GET_RXDATA();
}

//AXISTREAMIN basic functions
void axistream_in_init(int base_address, uint16_t div) {
  //capture base address for good
  AXISTREAMIN_INIT_BASEADDR(base_address);
  
  //pulse soft reset
  AXISTREAMIN_SET_SOFTRESET(1);
  AXISTREAMIN_SET_SOFTRESET(0);

  //Set the division factor div
  //div should be equal to round (fclk/baudrate)
  //E.g for fclk = 100 Mhz for a baudrate of 115200 we should AXISTREAMIN_SET_DIV(868)
  AXISTREAMIN_SET_DIV(div);

  //enable TX and RX
  AXISTREAMIN_SET_TXEN(1);
  AXISTREAMIN_SET_RXEN(1);
}

void axistream_in_finish() {
  axistream_in_putc(EOT);
  axistream_in_txwait();
}

//Print string, excluding end of string (0)
void axistream_in_puts(const char *s) {
  while (*s) axistream_in_putc(*s++);
}

//Sends the name of the file to use, including end of string (0)
void axistream_in_sendstr (char* name) {
  int i=0;
  do
    axistream_in_putc(name[i]);
  while (name[i++]);
}

//Receives file into mem
int axistream_in_recvfile(char* file_name, char **mem) {

  axistream_in_puts(AXISTREAMIN_PROGNAME);
  axistream_in_puts (": requesting to receive file\n");

  //send file receive request
  axistream_in_putc (FRX);

  //send file name
  axistream_in_sendstr(file_name);


  //receive file size
  int file_size = (unsigned int) axistream_in_getc();
  file_size |= ((unsigned int) axistream_in_getc()) << 8;
  file_size |= ((unsigned int) axistream_in_getc()) << 16;
  file_size |= ((unsigned int) axistream_in_getc()) << 24;

  //allocate space for file if file pointer not initialized
  if((*mem) == NULL) {
    (*mem) = (char *) malloc(file_size);
    if ((*mem) == NULL) {
      axistream_in_puts(AXISTREAMIN_PROGNAME);
      axistream_in_puts("Error: malloc failed");
    }
  }

  //send ACK before receiving file
  axistream_in_putc(ACK);

  //write file to memory
  for (int i = 0; i < file_size; i++) {
    (*mem)[i] = axistream_in_getc();
  }

  axistream_in_puts(AXISTREAMIN_PROGNAME);
  axistream_in_puts(": file received\n");

  return file_size;
}

//Sends mem contents to a file
void axistream_in_sendfile(char *file_name, int file_size, char *mem) {

  axistream_in_puts(AXISTREAMIN_PROGNAME);
  axistream_in_puts(": requesting to send file\n");

  //send file transmit command
  axistream_in_putc(FTX);
	
  //send file name
  axistream_in_sendstr(file_name);
	
  // send file size
  axistream_in_putc((char)(file_size & 0x0ff));
  axistream_in_putc((char)((file_size & 0x0ff00) >> 8));
  axistream_in_putc((char)((file_size & 0x0ff0000) >> 16));
  axistream_in_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // send file contents
  for (int i = 0; i < file_size; i++)
    axistream_in_putc(mem[i]);

  axistream_in_puts(AXISTREAMIN_PROGNAME);
  axistream_in_puts(": file sent\n");
}
