#include "iob-uart.h"

//Sends the name of the file to use
void uart_sendfileID (char* name) {
	int i;
	int name_size = strlen(name);
	
	//send name size
  uart_putc((char)(name_size & 0x0ff));
  uart_putc((char)((name_size & 0x0ff00) >> 8));
  uart_putc((char)((name_size & 0x0ff0000) >> 16));
  uart_putc((char)((name_size & 0x0ff000000) >> 24));
  
  //send name
  for (i=0; i<name_size; i++) 
  	uart_putc(name[i]);
  
}


//Receives file into mem
void uart_getfile(char* file_name, char* mem) {

  uart_printf ("%s: Receiving file %s\n", PROGNAME, file_name);
  uart_endtext(); //free host from text mode
  
  uart_startrecvfile();
  
	//Wait for PC ACK
  while (uart_getc() != ACK);	
  
  uart_sendfileID(file_name);
	
  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;
  
  // Write file to memory
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }

  uart_starttext();
  uart_printf("%s: File received (%d bytes)\n", PROGNAME, file_size);
  
}

//Sends content of mem to a file
void uart_sendfile(unsigned int file_size, char* file_name, char *mem) {

  uart_printf("%s: Sending file %s\n", PROGNAME, file_name);
  uart_endtext();
  
  uart_startsendfile();

	//Wait for PC ACK
  while (uart_getc() != ACK);
	
	uart_sendfileID(file_name);
	
  // send file size
  uart_putc((char)(file_size & 0x0ff));
  uart_putc((char)((file_size & 0x0ff00) >> 8));
  uart_putc((char)((file_size & 0x0ff0000) >> 16));
  uart_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // send file contents
  for (unsigned int i = 0; i < file_size; i++) {
    uart_putc(mem[i]);
  }

  uart_starttext();
  uart_printf("%s: File sent (%d bytes)\n",  PROGNAME, file_size);
}
