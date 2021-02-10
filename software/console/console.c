#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>   // File Control Definitions
#include <termios.h> // POSIX Terminal Control Definitions
#include <unistd.h>  // UNIX Standard Definitions
#include <errno.h>   // ERROR Number Definitions
#include <time.h>
#include "iob-uart-ascii.h"

#define PROGNAME "IOb-Console"

static int serial_fd;

//print error
void cnsl_perror (char * mesg) {
  printf(PROGNAME); printf(": %s\n", mesg);
  exit(1);
}

void cnsl_getchar(char *byte) {
  int nbytes;
  do {
    nbytes = (int) read(serial_fd, &byte, 1);
  } while (!(nbytes > 0));
}

void cnsl_putchar(char byte) {
  int nbytes;
  do nbytes = (int) write(serial_fd, &byte, 1);
  while (nbytes <= 0);
}


// send file to target
void sendFile(char *name) {
  FILE *fp;
  int file_size;
  char *buf;
  int i;
  
  //open data file
  fp = fopen(name, "rb");
  if (!fp)
    cnsl_perror("sendFile: Can't open file %s\n");
  
  //get file size
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  rewind(fp);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");

  printf(PROGNAME); printf(": starting transfer of %s (%d bytes)...\n",name, file_size);

  //send file size
  while (write(serial_fd, &file_size, 4) <= 0);
  
  //read file into buffer
  if (fread(buf, sizeof(char), file_size, fp) <= 0)
    cnsl_perror("can't read file\n");
    
  //send buffer
  for(i=0;i<file_size;i++)
    cnsl_putchar(buf[i]);
          
  //DEBUG
  //printf("buffer[%u] = %x\n", i, byte);
  
  printf (PROGNAME); printf(": file transfer complete\n");
  
  free(buf);
  fclose(fp);

}

void recvFile(char *name) {
  FILE *fp;
  unsigned int file_size = 0;
  
  int nbytes;
  char *buf;
  unsigned int i;

  //open data file
  fp = fopen(name, "wb");
  if (!fp)
    cnsl_perror("recvFile: Can't open file\n");

  
  printf(PROGNAME); printf(": starting %s reception...\n", name);  
  
  //receive file size
  do nbytes = (int) read(serial_fd, &file_size, sizeof(int));
  while (nbytes <= 0);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");

  
  //receive file into buffer
  for (i=0; i<file_size;i=i+nbytes)
    cnsl_getchar( &buf[i]);

  //save buffer into file
  if( fwrite(buf, sizeof(char), file_size, fp) <= 0)
    cnsl_perror("recvFile: failed to write file\n");

  //DEBUG
  //printf("buffer[%u] = %x\n", i, byte);
    
  printf (PROGNAME); printf(": file reception complete. %d bytes received\n", file_size);

  free(buf);
  fclose(fp);

}

//load firmware file into target
void cnsl_sendfile() {
  FILE *fp;
  int file_size;
  char *buf;
  int i;
  
  //open file to sent
  fp = fopen("firmware.bin", "rb");
  if (!fp)
    cnsl_perror("sendFile: Can't open firmware.bin\n");
  
  //get file size
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  rewind(fp);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL)
    cnsl_perror("memory allocation failed\n");
  
  printf(PROGNAME); printf(": starting to load firmware with %d bytes...\n", file_size);
  
  //send file size
  while (write(serial_fd, &file_size, 4) <= 0);
  
  //read file into buffer
  if (fread(buf, sizeof(char), file_size, fp) <= 0)
    cnsl_perror("can't read file\n");
  
  //send file 1 byte at a time (fix for transfering large files)
  for(i=0;i<file_size;i++)
    cnsl_putchar(buf[i]);
  
  printf (PROGNAME); printf(": file loading complete\n");
  
  free(buf);
  fclose(fp);
}

int openSerialPort(char *serialPort) {
  struct termios SerialPortSettings;
  int fd;
  
  // Taken from: https://github.com/xanthium-enterprises/Serial-Port-Programming-on-Linux/blob/master/USB2SERIAL_Write/Transmitter%20(PC%20Side)/SerialPort_write.c
  
  printf("\n");
  printf("+-----------------------------------------------+\n");
  printf("|                   ");printf(PROGNAME);printf("                 |\n");
  printf("+-----------------------------------------------+\n");
  
  //------------------------------- Opening the Serial Port -------------------------------//
  
  // ttyUSB0 is the FT232 based USB2SERIAL Converter    //
  // O_RDWR Read/Write access to serial port            //
  // O_NOCTTY - No terminal will control the process    //
  // O_NDELAY - Non Blocking Mode, does not care about- //
  // -the status of DCD line, Open() returns immediatly //
  
  fd = open(serialPort, O_RDWR | O_NOCTTY | O_NDELAY);
  if (fd == -1)
    cnsl_perror("can't open serial port\n");
  
  //set attributes of the serial port using termios structure
  
  //get current configuration of the serial interface
  if (tcgetattr(fd, &SerialPortSettings) < 0)
    cnsl_perror("can't get configuration of serial port\n");


  
  //set baud rate to 115200
  if (cfsetispeed(&SerialPortSettings, B115200) < 0 ||
      cfsetospeed(&SerialPortSettings, B115200) < 0)
    cnsl_perror("can't set baud rate of serial port\n");

  
  //                                                             //
  // Input flags - Turn off input processing                     //
  //                                                             //
  // convert break to null byte, no CR to NL translation,        //
  // no NL to CR translation, don't mark parity errors or breaks //
  // no input parity check, don't strip high bit off,            //
  // no XON/XOFF software flow control both i/p and o/p          //
  //                                                             //
  SerialPortSettings.c_iflag &= ~(IGNBRK | BRKINT | ICRNL | INLCR |
                                  PARMRK | INPCK | ISTRIP | IXON |
                                  IXOFF | IXANY);
  
  //                                                             //
  // Output flags - Turn off output processing                   //
  //                                                             //
  // no CR to NL translation, no NL to CR-NL translation,        //
  // no NL to CR translation, no column 0 CR suppression,        //
  // no Ctrl-D suppression, no fill characters, no case mapping, //
  // no local output processing                                  //
  //                                                             //
  // config.c_oflag &= ~(OCRNL | ONLCR | ONLRET |                //
  //                     ONOCR | ONOEOT| OFILL | OLCUC | OPOST); //
  SerialPortSettings.c_oflag = 0;
  
  //                                                 //
  // No line processing                              //
  //                                                 //
  // echo off, echo newline off, canonical mode off, //
  // extended input processing off, signal chars off //
  //                                                 //
  SerialPortSettings.c_lflag &= ~(ECHO | ECHONL | ICANON | IEXTEN | ISIG);
  
  //                                                   //
  // Turn off character processing                     //
  //                                                   //
  // clear current char size mask, no parity checking, //
  // no output processing, force 8 bit input, set      //
  // 1 stop bit and enable receiver                    //
  //                                                   //
  SerialPortSettings.c_cflag &= ~(CRTSCTS | CSTOPB | CSIZE | PARENB | CLOCAL);
  SerialPortSettings.c_cflag |= CS8 | CREAD;
  
  //                                                //
  // One input byte is enough to return from read() //
  // Inter-character timer off                      //
  //                                                //
  SerialPortSettings.c_cc[VMIN]  = 1;
  SerialPortSettings.c_cc[VTIME] = 0;
  
  // Apply new configuration
  if (tcsetattr(fd, TCSANOW, &SerialPortSettings)) {
    close(fd);
    cnsl_perror("\n  ERROR ! in Setting attributes\n");
  } else {
    printf("\n  BaudRate = 115200 \n  StopBits = 1 \n  Parity   = None\n\n");
  }
  
  //------------------------------- Write data to serial port -----------------------------//
  
  return fd;
}

void usage(char *message){
  cnsl_perror("usage: ./console -s <serial port> [ -f <firmware file> ]\n");
}


//
// MAIN ROUTINE
//

int main(int argc, char* argv[]) {
  char *serialPort = 0;
  char *fwFile = 0;
  int i;
  
  if (argc < 3)
    usage("PROGNAME: not enough program arguments\n");
  
  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-' && !argv[i][2]) {
      if (argv[i][1] == 's') {
        serialPort = argv[++i];
      } else if (argv[i][1] == 'f') {
        fwFile = "firmware.bin";
      } else usage("PROGNAME: unexpected argument\n");
    } else  usage("PROGNAME: unexpected argument\n");
  }
  
  //open serial port
  serial_fd = openSerialPort(serialPort);

  //server loop
  char byte;
  int gotENQ = 0;

  while (1) {

    //get byte from target
    cnsl_getchar(&byte);

    //process command
    switch (byte) {
          
    case ENQ:
      if(!gotENQ) {
        gotENQ = 1;
        if(fwFile) {
          cnsl_putchar(FRX);
          cnsl_sendfile();
        } else
          cnsl_putchar(ACK);
        break;
      }
      
    case EOT:
      exit(0);
      break;
      
      
    default:
      printf("%c", byte);
      fflush(stdout);

    }

  }
  
  close(serial_fd);

}
