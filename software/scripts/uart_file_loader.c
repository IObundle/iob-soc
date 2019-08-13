#include <stdio.h>
#include <fcntl.h>   /* File Control Definitions           */
#include <termios.h> /* POSIX Terminal Control Definitions */
#include <unistd.h>  /* UNIX Standard Definitions 	   */ 
#include <errno.h>   /* ERROR Number Definitions           */
#include <time.h>
#define N 9*4096 /*Number of characters to send*/
#define N_hex 9*4096 /*Number of character in the .hex*/
#define sleep_time_us 20

int main(int argc, char* argv[]){ 
  int serial_fd;/*File Descriptor*/
  FILE *file_fd;

  struct termios SerialPortSettings;	/* Create the structure*/

  int *file_buffer [N_hex];
  size_t file_size;
  
  unsigned char *char_file_buffer;
  /*int counter;*/
  char write_buffer[3];	/* Buffer containing characters to write into port (3 to avoid the \0)     */	
  char hex_buffer[2];
  char read_buffer [N];
  int  bytes_written; /* Value for storing the number of bytes written to the port */ 
  int  bytes_read;
 
  int i = 0;  	

  clock_t begin;
  clock_t end;
  double time_spent;

  if(argc<2)
    {
      puts("Missing arguments, please the the file with with it's correct path if necessary.\n");
      return(0);
    }


  /* Taken from: https://github.com/xanthium-enterprises/Serial-Port-Programming-on-Linux/blob/master/USB2SERIAL_Write/Transmitter%20(PC%20Side)/SerialPort_write.c */
     
  printf("\n +----------------------------------+");
  printf("\n |        Serial Port Write         |");
  printf("\n +----------------------------------+");

  /*------------------------------- Opening the Serial Port -------------------------------*/

  /* Change /dev/ttyUSB0 to the one corresponding to your system */

  serial_fd = open("/dev/ttyUSB0",O_RDWR | O_NOCTTY | O_NDELAY);	/* ttyUSB0 is the FT232 based USB2SERIAL Converter   */	   /* O_RDWR Read/Write access to serial port           */
  /* O_NOCTTY - No terminal will control the process   */
  /* O_NDELAY -Non Blocking Mode,Does not care about-  */
  /* -the status of DCD line,Open() returns immediatly */                                        	
  if(serial_fd == -1)/* Error Checking */
    printf("\n  Error! in Opening ttyUSB0  ");
  else
    printf("\n  ttyUSB0 Opened Successfully ");

	
  /*---------- Setting the Attributes of the serial port using termios structure --------- */


  tcgetattr(serial_fd, &SerialPortSettings);	/* Get the current attributes of the Serial port */

  cfsetispeed(&SerialPortSettings,B115200); /* Set Read  Speed as 115200                       */
  cfsetospeed(&SerialPortSettings,B115200); /* Set Write Speed as 115200                       */

  SerialPortSettings.c_cflag &= ~PARENB;   /* Disables the Parity Enable bit(PARENB),So No Parity   */
  SerialPortSettings.c_cflag &= ~CSTOPB;   /* CSTOPB = 2 Stop bits,here it is cleared so 1 Stop bit */
  SerialPortSettings.c_cflag &= ~CSIZE;	 /* Clears the mask for setting the data size             */
  SerialPortSettings.c_cflag |=  CS8;      /* Set the data bits = 8                                 */
	
  SerialPortSettings.c_cflag &= ~CRTSCTS;       /* No Hardware flow Control                         */
  SerialPortSettings.c_cflag |= CREAD | CLOCAL; /* Enable receiver,Ignore Modem Control lines       */ 


  SerialPortSettings.c_iflag &= ~(IXON | IXOFF | IXANY);          /* Disable XON/XOFF flow control both i/p and o/p */
  SerialPortSettings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);  /* Non Cannonical mode                            */

  SerialPortSettings.c_oflag &= ~OPOST;/*No Output Processing*/

  if((tcsetattr(serial_fd,TCSANOW,&SerialPortSettings)) != 0) /* Set the attributes to the termios structure*/
    printf("\n  ERROR ! in Setting attributes");
  else
    printf("\n  BaudRate = 115200 \n  StopBits = 1 \n  Parity   = none");
	
  /*------------------------------- Write data to serial port -----------------------------*/

  file_fd = fopen(argv[1], "r");

  if (file_fd == NULL){
    printf("Can't open the file selected. Don't forget to add an valid pathed file.\n");
    return(0);
  }


  file_size = fread(file_buffer, sizeof(char), sizeof(file_buffer), file_fd);
  if (file_size == 0)
    printf("Warning: File has no values to read\n");

  char_file_buffer = (unsigned char*) file_buffer;

  fclose(file_fd);

  /*printf("\nPrintng as string:\n%s\n", file_buffer);*/
  /*printf("Printing as unsigned char*:\n");
    for (counter=0; counter < N; counter++) printf("%c ", char_file_buffer[counter]);
  */
   
  printf("\nStarting File Transfer...\n");
  begin = clock();

  for (i = 0; i <N ; i++){
    if (char_file_buffer[i] == 10){/*printf("paragrafo\n");*/}else{
      /* printf ("\nsending:%c\n", char_file_buffer[i]);*/
      write_buffer[0] = (char) char_file_buffer[i++];
      write_buffer[1] = (char) char_file_buffer[i];
      write_buffer[2] = 0;
      
      sscanf(write_buffer, "%2x", (unsigned int *) hex_buffer);
      bytes_written = write(serial_fd, hex_buffer, 1);/* use write() to send data to port, with the size of 1 byte */
      if (bytes_written == -1)
	printf("Failed to send data\n");
      /* "serial_fd" - file descriptor pointing to the opened serial port */
      /*	"write_buffer" - address of the buffer containing data         */
      /* "sizeof(write_buffer)" - No of bytes to write                  */	
      /*printf("\n  %02x written to ttyUSB0",0x000000ff & (unsigned int) hex_buffer[0]);*/
      /*printf("\n  %d Bytes written to ttyUSB0", bytes_written);*/
      /*printf("\n +----------------------------------+\n\n");*/
      usleep(sleep_time_us);
    }

  }
  end = clock ();
  time_spent = ((double) (end - begin)) / CLOCKS_PER_SEC;
  printf ("\nUART transfer complete.\n");
  printf("The file transfer took %f seconds.\n", time_spent);

  while(1){
    bytes_read = read(serial_fd, read_buffer, sizeof(char));
    if(bytes_read > 0)
      putchar(read_buffer[0]);
  }

  close(serial_fd);/* Close the Serial port */
  return(0);
}
