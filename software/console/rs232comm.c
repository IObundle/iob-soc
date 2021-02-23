#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>   // File Control Definitions
#include <termios.h> // POSIX Terminal Control Definitions
#include <unistd.h>  // UNIX Standard Definitions
#include <errno.h>   // ERROR Number Definitions
#include <time.h>

#include "console.h"

#define PROGNAME "IOb-Console"

static int serial_fd;

char cnsl_getchar() {
  char byte;
  int nbytes;
  do {
    nbytes = (int) read(serial_fd, &byte, 1);
  } while (nbytes <= 0);
  return byte;
}

void cnsl_putchar(char byte) {
  int nbytes;
  do {
    nbytes = (int) write(serial_fd, &byte, 1);
  } while (nbytes <= 0);
}

int cnsl_getint() {
  int i;
  int nbytes;
  do {
    nbytes = (int) read(serial_fd, &i, 4);
  } while (nbytes <= 0);
  return i;
}

void cnsl_putint(int i) {
  int nbytes;
  do {
    nbytes = (int) write(serial_fd, &i, 4);
  } while (nbytes <= 0);
}

void cnsl_open(char *serialPort) {
  struct termios SerialPortSettings;
  
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
  
  serial_fd = open(serialPort, O_RDWR | O_NOCTTY | O_NDELAY);
  if (serial_fd == -1)
    cnsl_perror("can't open serial port\n");

  //set attributes of the serial port using termios structure
  
  //get current configuration of the serial interface
  if (tcgetattr(serial_fd, &SerialPortSettings) < 0)
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

  //diable buffering
  tcflush(serial_fd, TCIFLUSH);

  // Apply new configuration
  if (tcsetattr(serial_fd, TCSANOW, &SerialPortSettings)) {
    close(serial_fd);
    cnsl_perror("\n  ERROR ! in Setting attributes\n");
  } else {
    printf("\n  BaudRate = 115200 \n  StopBits = 1 \n  Parity   = None\n\n");
  }
  
  //------------------------------- Write data to serial port -----------------------------//
  
}

void cnsl_close() {
  close(serial_fd);
}
