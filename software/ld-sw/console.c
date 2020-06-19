#include <stdio.h>
#include <fcntl.h>   // File Control Definitions
#include <termios.h> // POSIX Terminal Control Definitions
#include <unistd.h>  // UNIX Standard Definitions
#include <errno.h>   // ERROR Number Definitions
#include <time.h>
#include "iob-uart.h"

#define WAIT_FOR_RISCV 20000

// Uncomment this line for debug
//#define DEBUG

int connect(int serial_fd) {
  unsigned char byte;
  int nbytes;
  
  byte = ENQ;
  nbytes = (int) write(serial_fd, &byte, 1);
  if (nbytes == -1) {
    printf("connect: Failed to send Ack\n");
  }
  
  do {
    do {
      nbytes = (int) read(serial_fd, &byte, 1);
    } while (nbytes <= 0);
  } while (byte != ENQ);
  byte = ACK;
  nbytes = (int) write(serial_fd, &byte, 1);
  if (nbytes == -1) {
    printf("connect: Failed to send Ack\n");
  }
  
  return 0;
}

int print (int serial_fd) {
  unsigned char byte;
  int nbytes;
  
  do {
    do {
      nbytes = (int) read(serial_fd, &byte, 1);
    } while (nbytes <= 0);
  } while (byte != STX);
  
  while (1) {
    do {
      nbytes = (int) read(serial_fd, &byte, 1);
    } while (nbytes <= 0);
    
    if (byte == ETX || byte == ENQ) { // Finish
      break;
    } else { // Print char
      printf("%c", byte);
    }
  }
  
  return 0;
}

int run(int serial_fd) {
  unsigned char byte;
  int nbytes;
  
  byte = EOT;
  nbytes = (int) write(serial_fd, &byte, 1);
  if (nbytes == -1) {
    printf("run: Failed to send EOT\n");
  }
  
  print(serial_fd);
  
  return 0;
}

int sendFile(int serial_fd, char *name) {
  FILE *file_fd;
  unsigned int file_size;
  
  unsigned int i;
  unsigned char byte;
  int nbytes;
  
  clock_t begin;
  clock_t end;
  double time_spent;
  unsigned int count = 0;
  
  file_fd = fopen(name, "rb");
  if (!file_fd) {
    printf("sendFile: Can't open the file selected. Don't forget to add an valid pathed file.\n");
    return -1;
  }
  
  // Get file size
  fseek(file_fd, 0L, SEEK_END);
  file_size = ftell(file_fd);
  rewind(file_fd);
  
  byte = STX;
  nbytes = (int) write(serial_fd, &byte, 1);
  if (nbytes == -1) {
    printf("sendFile: Failed to send STX\n");
  }
  
  print(serial_fd);
  
  printf("\nStarting File '%s' Transfer...\n", name);
  printf("file_size = %u\n", file_size);
  begin = clock();
  
  // Send file size
  nbytes = (int) write(serial_fd, &file_size, 4);
  if (nbytes == -1) {
    printf("sendFile: Failed to send data\n");
  }
  
  // Send file
  for (i = 0; i < file_size; i++) {
    nbytes = (int) fread(&byte, sizeof(unsigned char), 1, file_fd);
    if (nbytes != 1) {
      printf("sendFile: Failed to read byte from file\n");
    }
    
    nbytes = (int) write(serial_fd, &byte, 1);
    if (nbytes == -1) {
      printf("sendFile: Failed to send data\n");
    }
    
    if (!(i%200)) {
      count++;
      usleep(WAIT_FOR_RISCV);
    }
#ifdef DEBUG
    printf("buffer[%u] = %x\n", i, byte);
#endif
  }
  
  end = clock();
  time_spent = ((double) (end - begin)) / CLOCKS_PER_SEC + (double)count * WAIT_FOR_RISCV/1000000.0;
  printf ("\nUART transfer complete.\n");
  printf("The file transfer took %f seconds.\n", time_spent);
  
  fclose(file_fd);
  
  print(serial_fd);
  
  return 0;
}

int receiveFile(int serial_fd, char *name) {
  FILE *file_fd;
  unsigned int file_size = 0;
  
  unsigned int i;
  int nbytes;
  unsigned char byte;
  
  clock_t begin;
  clock_t end;
  double time_spent;
  
  file_fd = fopen(name, "wb");
  if (!file_fd) {
    printf("receiveFile: Can't open the file selected. Don't forget to add an valid pathed file.\n");
    return -1;
  }
  
  byte = ETX;
  nbytes = (int) write(serial_fd, &byte, 1);
  if (nbytes == -1) {
    printf("receiveFile: Failed to send ETX\n");
  }
  
  print(serial_fd);
  
  printf("\nStarting File '%s' Transfer...\n", name);  
  begin = clock();
  
  // Get file size
  for (i = 0; i < 4; i++) {
    do {
      nbytes = (int) read(serial_fd, &byte, 1);
    } while (nbytes <= 0);
    
    file_size |= byte << (i*8);
  }
  
  // Get file
  for (i = 0; i < file_size; i++) {
    do {
      nbytes = (int) read(serial_fd, &byte, 1);
    } while (nbytes <= 0);
    
    nbytes = (int) fwrite(&byte, sizeof(char), 1, file_fd);
    if (nbytes != 1) {
      printf("receiveFile: Failed to write byte in file\n");
    }
#ifdef DEBUG
    printf("buffer[%u] = %x\n", i, byte);
#endif
  }
  
  end = clock();
  time_spent = ((double) (end - begin)) / CLOCKS_PER_SEC;
  
  printf("file_size = %d\n", file_size);
  printf ("\nUART transfer complete.\n");
  printf("The file transfer took %f seconds.\n", time_spent);
  
  fclose(file_fd);
  
  print(serial_fd);
  
  return 0;
}

int openSerialPort(char *serialPort) {
  struct termios SerialPortSettings;
  int fd;
  
  // Taken from: https://github.com/xanthium-enterprises/Serial-Port-Programming-on-Linux/blob/master/USB2SERIAL_Write/Transmitter%20(PC%20Side)/SerialPort_write.c
  
  printf("\n +----------------------------------+");
  printf("\n |           Serial Port            |");
  printf("\n +----------------------------------+");
  
  //------------------------------- Opening the Serial Port -------------------------------//
  
  // ttyUSB0 is the FT232 based USB2SERIAL Converter    //
  // O_RDWR Read/Write access to serial port            //
  // O_NOCTTY - No terminal will control the process    //
  // O_NDELAY - Non Blocking Mode, does not care about- //
  // -the status of DCD line, Open() returns immediatly //
  
  fd = open(serialPort, O_RDWR | O_NOCTTY | O_NDELAY);
  if (fd == -1) {
    printf("\n  Error! in Opening '%s'", serialPort);
    return 0;
  } else {
    printf("\n  '%s' Opened Successfully", serialPort);
  }
	
  // ---------- Setting the Attributes of the serial port using termios structure --------- //
  
  // Get the current configuration of the serial interface
  if (tcgetattr(fd, &SerialPortSettings) < 0) {
    printf("\n  Error! in Getting '%s' configuration", serialPort);
    return 0;
  }
  
  // Set Read Speed and Write as 115200
  if (cfsetispeed(&SerialPortSettings, B115200) < 0 ||
      cfsetospeed(&SerialPortSettings, B115200) < 0) {
    printf("\n  Error! in Setting baudrate '%s'", serialPort);
    return 0;
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
    return 0;
  } else {
    printf("\n  BaudRate = 115200 \n  StopBits = 1 \n  Parity   = None\n\n");
  }
  
  //------------------------------- Write data to serial port -----------------------------//
  
  return fd;
}

void usage(char *message) {
  printf("usage: %s\n", message);
  printf("       ./console -s <serial port> -f <firmware file> -i <input file> -o <output file>\n");
  return;
}

int main(int argc, char* argv[]) {
  char *serialPort = 0;
  int serial_fd;
  char *fwFile = 0;
  char *inputFile = 0;
  char *outputFile = 0;
  int i;
  
  if (argc < 3) {
    usage("Missing arguments");
    return -1;
  }
  
  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      if (argv[i][1] == 's') {
        serialPort = argv[++i];
      } else if (argv[i][1] == 'f') {
        fwFile = argv[++i];
      } else if (argv[i][1] == 'i') {
        inputFile = argv[++i];
      } else if (argv[i][1] == 'o') {
        outputFile = argv[++i];
      } else {
        usage("Unexpected argument");
        return -1;
      }
    } else {
      usage("Unexpected argument");
      return -1;
    }
  }
  
  serial_fd = openSerialPort(serialPort);
  if (!serial_fd) {
    return -1;
  }
  
  // Sync with target
  connect(serial_fd);
  
  if (fwFile) { // Send firmware file
    sendFile(serial_fd, fwFile);
  }
  
  if (inputFile) { // Send input file
    sendFile(serial_fd, inputFile);
  }
  
  // Run application
  run(serial_fd);
  
  if (outputFile) { // Receive output file
    receiveFile(serial_fd, outputFile);
  }
  
  close(serial_fd);
  
  return 0;
}
