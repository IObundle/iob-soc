#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "iob-uart.h"
#include "system.h"
#include "iob-eth.h"

#define DEVVAL 868

#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define Address_write 0x9004 //address where the writting starts
#define N 1000

#define ETH_BYTES (256-18) //minimum ethernet payload excluding FCS

#define WEIGHTS_SIZE 232000000 //in bytes

volatile int * vect;

// returns ceil(num/den)
int ceil(int num, int den){
  int retVal = 0;
  if(den == 0)
    return 0;

  int quocient = num/den;

  if(quocient*den < num)
    return quocient+1;
  else
    return quocient;
}


void main()
{ 
  int counter, reg = 0, i=0, j=0, k=0 ;
  unsigned char ledvar = 0;
  unsigned char Numb = 0;
  int line=0;
  char temp=0;


  int rcv_timeout = 5000;

  int num_frames = ceil(WEIGHTS_SIZE, ETH_NBYTES);
  char data_rcv[ETH_NBYTES+18];

  uart_init(UART_BASE,UART_CLK_FREQ/UART_BAUD_RATE);
   
  //uart_write_wait();
  uart_puts("... Initializing program in main memory:\n");
  vect = (volatile int*) DDR_BASE;
  uart_printf("Receiving data from ethernet to ddr\n");

  //init ethernet
  eth_init(ETH_BASE);
  eth_set_rx_payload_size(ETH_NBYTES);

  eth_printstatus();

  //loop to receive weights via ethernet
  for(counter=0; counter< num_frames; counter++){

    //wait for data frame
    while(eth_rcv_frame(data_rcv, ETH_NBYTES+18, rcv_timeout) != 0 );

    //save frame data to ddr
    for(i=0;i<ETH_NBYTES/4;i++ ){ //NOTE: assuming multiple of 4 ETH_NBYTES
      line = 0;
      for (j = 3, k=0; j >= 0 ; j--, k++) {
	//read the byte to a char and append it to the line
	temp = data_rcv(14+i*4+k);
	line+=temp << (8*j); //number of shitfs = number of bits in a byte

      }
      //save 4 byte to ddr at a time
      vect[counter*ETH_NBYTES/4 + i] = line;
    }
  }

  uart_puts("Transmission Complete\n");

}
