#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "console.h"

//to do: is this really a uart thing ?
//seems to be bootloader related and not uart related

#include "iob-uart-ascii.h"


#define PROGNAME "IOb-Console"

//print error
void cnsl_perror (char * mesg) {
  printf(PROGNAME); printf(": %s\n", mesg);
  exit(1);
}

//receive file from target
void cnsl_recvfile(char *name) {
  FILE *fp;
  unsigned int file_size = 0;
  char *buf;
  unsigned int i;

  //open data file
  fp = fopen(name, "wb");
  if (!fp)
    cnsl_perror("can't open file to store received file\n");

  
  printf(PROGNAME); printf(": receiving file...%s\n", name);  
  
  //receive file size
  file_size = cnsl_getint();

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");

  
  //receive file into buffer
  for (i=0; i<file_size; i++)
    cnsl_getchar( &buf[i]);

  //save buffer into file
  if( fwrite(buf, sizeof(char), file_size, fp) <= 0)
    cnsl_perror("failed to write file\n");

  //DEBUG
  //printf("buffer[%u] = %x\n", i, byte);
    
  printf (PROGNAME); printf(": file of size %d bytes received\n", file_size);

  free(buf);
  fclose(fp);

}

//send file to target
void cnsl_sendfile(char *name) {
  FILE *fp;
  int file_size;
  char *buf;
  int i;
  
  //open file to sent
  fp = fopen(name, "rb");
  if (!fp)
    cnsl_perror("can't open file to send%s\n");
  
  //get file size
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  rewind(fp);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");
  
  printf(PROGNAME); printf(": sending file of size %d bytes...\n", file_size);
  
  //send file size
  cnsl_putint(file_size);
  
  //read file into buffer
  if (fread(buf, sizeof(char), file_size, fp) <= 0)
    cnsl_perror("can't read file\n");
  
  //send file 1 byte at a time (fix for transfering large files)
  for(i=0;i<file_size;i++)
    cnsl_putchar(buf[i]);
  
  printf (PROGNAME); printf(": file sent\n");
  
  free(buf);
  fclose(fp);
}

void usage(char *message){
  cnsl_perror("usage: ./console -s <serial port> [ -f <firmware file> ]\n");
}

//
// MAIN ROUTINE
//

int main(int argc, char* argv[]) {

  char *devname = 0;
  char *fwFile = 0;
  int i;
  
  if (argc < 3)
    usage("PROGNAME: not enough program arguments\n");
  
  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-' && !argv[i][2]) {
      if (argv[i][1] == 's') {
        devname = argv[++i];
      } else if (argv[i][1] == 'f') {
        fwFile = "firmware.bin";
      } else usage("PROGNAME: unexpected argument\n");
    } else  usage("PROGNAME: unexpected argument\n");
  }
  
  //open serial port
  cnsl_open(devname);

  //server loop
  char byte;
  int gotENQ = 0;

  while (1) {

    //get byte from target
    byte = cnsl_getchar();

    //process command
    switch (byte) {
          
    case ENQ:
      if(!gotENQ) {
        gotENQ = 1;
        if(fwFile) {
          cnsl_putchar(FRX);
          cnsl_sendfile(fwFile);
        } else
          cnsl_putchar(ACK);
      }
      break;
      
    case EOT:
      printf(PROGNAME); printf(": exiting...\n");
      exit(0);
      break;
      
    default:
      printf("%c", byte);
      fflush(stdout);

    }

  }
  
  cnsl_close();
  
}
