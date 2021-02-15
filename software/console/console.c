#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "console.h"
#include "iob-uart.h"

#define PROGNAME "IOb-Console"

//print error
void cnsl_perror (char * mesg) {
  printf(PROGNAME); printf(": %s\n", mesg);
  exit(1);
}

//receive file name
void cnsl_recvstr(char *name) {
  int i=0;
  do name[i] = cnsl_getchar(); while (name[i++]);
  printf(PROGNAME); printf(": file name %s\n", name);  
}

//receive file from target
void cnsl_recvfile() {
  FILE *fp;
  int file_size = 0;
  char *buf;
  char name[80];
  int i;
  
  //receive file name
  cnsl_recvstr(name);

  //open data file
  fp = fopen(name, "wb");
  if (!fp)
    cnsl_perror("can't open file to store received file\n");

  printf(PROGNAME); printf(": receiving file...\n");  
  
  //receive file size
  file_size = cnsl_getint();

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");

  
  //receive file into buffer
  for (i=0; i<file_size; i++)
    buf[i] = cnsl_getchar();

  //save buffer into file
  if( fwrite(buf, sizeof(char), file_size, fp) <= 0)
    cnsl_perror("failed to write file\n");
    
  printf (PROGNAME); printf(": file of size %d bytes received\n", file_size);

  free(buf);
  fclose(fp);

}

//send file to target
void cnsl_sendfile() {
  FILE *fp;
  int file_size;
  char *name;
  char *buf;
  int i;

  //receive file name
  name = malloc(80);
  cnsl_recvstr(name);

  printf(PROGNAME); printf(": file name: %s\n", name);
  
  //open file to sent
  fp = fopen(name, "rb");
  if (!fp)
    cnsl_perror("can't open file to send\n");
  
  //get file size
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  rewind(fp);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");
  
  printf(PROGNAME); printf(": file size: %d bytes\n", file_size);
  
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
  cnsl_perror(message);
}

//
// MAIN ROUTINE
//

int main(int argc, char* argv[]) {

  char *devname = 0;
  int i;
  int load_fw = 0;
  
  if (argc < 3)
    usage("PROGNAME: not enough program arguments\n");
  
  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-' && !argv[i][2]) {
      if (argv[i][1] == 's') {
        devname = argv[++i];
      } else if (argv[i][1] == 'f') {
        load_fw = 1;
      } else usage("PROGNAME: unexpected argument\n");
    } else  usage("PROGNAME: unexpected argument\n");
  }
  
  //open connection
  cnsl_open(devname);

  //server loop
  char byte;
  int gotENQ = 0;

  printf(PROGNAME); printf(": connecting");

  while (1) {

    //get byte from target
    byte = cnsl_getchar();

    //process command
    switch (byte) {
          
    case ENQ:
      printf(".");
      if(!gotENQ) {
        gotENQ = 1;
        if(load_fw)
          cnsl_putchar(FRX);
        else
          cnsl_putchar(ACK);
      }
      break;
      
    case EOT:
      printf(PROGNAME); printf(": exiting...\n");
      exit(0);
      break;
      
    case FRX:
      printf(PROGNAME); printf(": sending file\n");
      cnsl_sendfile();
      break;

    case FTX:
      printf(PROGNAME); printf(": receiving file\n");
      cnsl_recvfile();
      break;

    default:
      printf("%c", byte);
      fflush(stdout);
      
    }

  }
  
  cnsl_close();
  
}
