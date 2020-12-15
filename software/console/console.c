#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>   // File Control Definitions
#include <termios.h> // POSIX Terminal Control Definitions
#include <unistd.h>  // UNIX Standard Definitions
#include <errno.h>   // ERROR Number Definitions
#include <time.h>

#include "iob-uart-ascii.h"

#define PROGNAME "IOb-Console"

void connect(int serial_fd) {
  unsigned char byte;
  int nbytes = 0;

  //wait for taget to send ENQ 
  while (nbytes <= 0) {
    nbytes = (int) read(serial_fd, &byte, 1);
    //printf(PROGNAME); printf(": nbytes=%d byte=%d received from target\n", nbytes, byte);
    if ( nbytes > 0 && byte == ENQ)
      break;
    //this will unblock target block read
    byte = 0;
    while (write(serial_fd, &byte, 1) <= 0);
  }
  printf(PROGNAME); printf(": ENQ symbol received from target\n");
  
  //send ACK
  byte = ACK;
  while ( write(serial_fd, &byte, 1) <= 0);
}

//prints incoming chars until ETX or ENQ is received
void print (int serial_fd) {
  unsigned char byte;
  int nbytes;
  
  //printf(PROGNAME); printf(": Target to send STX symbol\n");
  //fflush(stdout);

  do {
    nbytes = (int) read(serial_fd, &byte, 1);
    //
  } while (!(nbytes > 0 && byte == STX));

  //printf(PROGNAME); printf(": Target to print chars\n");
  //fflush(stdout);

  while (1) {
    nbytes = (int) read(serial_fd, &byte, 1);

    if ( nbytes > 0 &&  (byte == ETX || byte == ENQ ) )
      break;

    if (nbytes == 1)
      printf("%c", byte);
  }
}

//send run signal
void run(int serial_fd) {
  unsigned char byte;
  printf(PROGNAME); printf(": Sending RUN command to target\n");
  byte = EOT;
  while (write(serial_fd, &byte, 1) <= 0);
  printf(PROGNAME); printf(": RUN command sent to target\n");
  fflush(stdout);

  print(serial_fd);
}

// send file to target
void sendFile(int serial_fd, char *name) {
  FILE *fp;
  int file_size;
  
  char byte;
  int nbytes;
  char *buf;

  //signal target to expect data
  byte = STX;
  do nbytes = (int) write(serial_fd, &byte, 1);
  while (nbytes <= 0);

  //open data file
  fp = fopen(name, "rb");
  if (!fp) {
    {printf(PROGNAME); printf(": sendFile: Can't open file\n");}
    exit(1);
  }
  
  //get file size
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  rewind(fp);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL) {
    printf(PROGNAME); printf(": memory allocation failed\n");
    exit(1);
  }
      
  //print incoming messages
  print(serial_fd);
  
  printf(PROGNAME); printf(": starting file transfer of %d bytes...\n", file_size);

  
  //send file size
  while ( write(serial_fd, &file_size, 4) <= 0);
  
  //read file into buffer
  if (fread(buf, sizeof(char), file_size, fp) <= 0) {
    printf(PROGNAME); printf(": can't read file\n");
    exit(1);
  }
  
    
  //send buffer
  int i=0;
  for(i=0;i<file_size;i++){
    //send 1 byte at a time - fix for transfering bigger firmwares
    while ( write(serial_fd, &(buf[i]), 1) <= 0 );
  }
          
  //DEBUG
  //printf("buffer[%u] = %x\n", i, byte);
  
  printf (PROGNAME); printf(": file transfer complete\n");
  
  free(buf);
  fclose(fp);
  
  // Print incoming messages
  print(serial_fd);
  
}

void receiveFile(int serial_fd, char *name) {
  FILE *fp;
  int file_size = 0;
  
  int nbytes;
  char byte;
  char *buf;

  //open data file
  fp = fopen(name, "wb");
  if (!fp) {
    printf(PROGNAME); printf(": receiveFile: Can't open file\n");
    exit(1);
  }

  //signal target to send data
  byte = ETX;
  while ( write(serial_fd, &byte, 1) <= 0 );
  
  printf(PROGNAME); printf(": starting file reception...\n");  
  
  //receive file size
  do nbytes = (int) read(serial_fd, &file_size, sizeof(int)); while (nbytes <= 0);

  //allocate space for internal file buffer
  if( (buf = malloc(file_size)) == NULL) {
    printf(PROGNAME); printf(": memory allocation failed\n");
    exit(1);
  }

  
  //receive file into buffer
  do nbytes = (int) read(serial_fd, buf, file_size); while (nbytes <= 0);
    
  if( fwrite(buf, sizeof(char), file_size, fp) <= 0) {
    printf(PROGNAME); printf(": receiveFile: failed to write file\n");
    exit(1);
  }

  //DEBUG
  //printf("buffer[%u] = %x\n", i, byte);
    
  printf (PROGNAME); printf(": file reception complete. %d bytes received\n", file_size);

  free(buf);
  fclose(fp);

  //print incoming messages
  print(serial_fd);
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
  if (fd == -1) {
    printf(PROGNAME); printf(": can't open %s\n", serialPort);
    exit(1);
  }

  
  //set attributes of the serial port using termios structure
  
  //get current configuration of the serial interface
  if (tcgetattr(fd, &SerialPortSettings) < 0) {
    printf(PROGNAME); printf(": can't get configuration of %s\n", serialPort);
    exit(1);
  }

  
  //set baud rate to 115200
  if (cfsetispeed(&SerialPortSettings, B115200) < 0 ||
      cfsetospeed(&SerialPortSettings, B115200) < 0) {
    printf(PROGNAME); printf(": can't set baud rate %s\n", serialPort);
    exit(1);
  }

  
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
    printf("\n  ERROR ! in Setting attributes\n");
    close(fd);
    exit(1);
  } else {
    printf("\n  BaudRate = 115200 \n  StopBits = 1 \n  Parity   = None\n\n");
  }
  
  //------------------------------- Write data to serial port -----------------------------//
  
  return fd;
}

void usage(char *message) {
  printf("usage: %s\n", message);
  printf("       ./console -s <serial port> -f <firmware file> -i <input file> -o <output file>\n");
  printf("       -f, -i and -o arguments are optional\n");
  exit(1);
}

int main(int argc, char* argv[]) {
  char *serialPort = 0;
  int serial_fd;
  char *fwFile = 0;
  char *inputFile = 0;
  char *outputFile = 0;
  int i;
  
  if (argc < 3)
    usage("PROGNAME: not enough program arguments\n");
  
  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-' && !argv[i][2]) {
      if (argv[i][1] == 's') {
        serialPort = argv[++i];
      } else if (argv[i][1] == 'f') {
        fwFile = argv[++i];
      } else if (argv[i][1] == 'i') {
        inputFile = argv[++i];
      } else if (argv[i][1] == 'o') {
        outputFile = argv[++i];
      } else usage("PROGNAME: unexpected argument\n");
    } else  usage("PROGNAME: unexpected argument\n");
  }
  
  serial_fd = openSerialPort(serialPort);
  if (!serial_fd)
    exit(1);
  
  //sync with target
  connect(serial_fd);
  printf(PROGNAME); printf(": Connected to target\n");
  fflush(stdout);

  //send firmware file
  if (fwFile) {
    sendFile(serial_fd, fwFile);
    printf(PROGNAME); printf(": Firmware sent to target\n");
    fflush(stdout);
  }
  
  //send input file
  if (inputFile) {
    sendFile(serial_fd, inputFile);
    printf(PROGNAME); printf(": Data file sent to target\n");
    fflush(stdout);
  }
  
  // Run application
  run(serial_fd);
  
  if (outputFile) { // Receive output file
    receiveFile(serial_fd, outputFile);
    printf(PROGNAME); printf(": Data file received from target\n");
    fflush(stdout);
  }
  
  close(serial_fd);
  
  return 0;
}
