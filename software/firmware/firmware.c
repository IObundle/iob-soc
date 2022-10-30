#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"
#include "iob_pcie_swreg.h"

#define C_PCI_DATA_WIDTH 64


char *send_string = "Sending this string as a file to console.\n"
                    "The file is then requested back from console.\n"
                    "The sent file is compared to the received file to confirm " 
                    "correct file transfer via UART using console.\n"
                    "Generating the file in the firmware creates an uniform "
                    "file transfer between pc-emul, simulation and fpga without"
                    " adding extra targets for file generation.\n";

// copy src to dst
// return number of copied chars (excluding '\0')
int string_copy(char *dst, char *src) {
    if (dst == NULL || src == NULL) {
        return -1;
    }
    int cnt = 0;
    while(src[cnt] != 0){
        dst[cnt] = src[cnt];
        cnt++;
    }
    dst[cnt] = '\0';
    return cnt;
}

// 0: same string
// otherwise: different
int compare_str(char *str1, char *str2, int str_size) {
    int c = 0;
    while(c < str_size) {
        if (str1[c] != str2[c]){
            return str1[c] - str2[c];
        }
        c++;
    }
    return 0;
}

int main()
{
  //init uart
  uart_init(UART_BASE,FREQ/BAUD);

  uart_puts("\n\n\nTest PCIE!\n\n\n");


  //while(1);
  
  IOB_PCIE_INIT_BASEADDR(PCIE_BASE);

  while(1) {

    
    //state 0

    while  (! IOB_PCIE_GET_LEN_VALID());

    IOB_PCIE_SET_LEN_ACK(1);
    int rLen =  IOB_PCIE_GET_LEN();

    long long rData [100];
  
    //state 1

    for (int i = 0 ; i < rLen ; i++){

      while(!IOB_PCIE_GET_DATA_VALID());
      
      rData[i] = IOB_PCIE_GET_DATAH();

  };
  

    
  //state 2

  IOB_PCIE_SET_CHNL(1);

  for (int i = 0 ; i < rLen ; i++){
    IOB_PCIE_SET_DATA_VALID(0);
    while (!IOB_PCIE_GET_DATA_REN());
    IOB_PCIE_SET_DATAH(rData[i]+2);
    IOB_PCIE_SET_DATA_VALID(1);
  };
};
    
  
  
  
  
  
  
  

    
  
  //test file send
  char *sendfile = malloc(1000);
  int send_file_size = 0;
  send_file_size = string_copy(sendfile, send_string);
  uart_sendfile("Sendfile.txt", send_file_size, sendfile);

  //test file receive
  char *recvfile = malloc(10000);
  int file_size = 0;
  file_size = uart_recvfile("Sendfile.txt", recvfile);

  //compare files
  if (compare_str(sendfile, recvfile, send_file_size)) {
      printf("FAILURE: Send and received file differ!\n");
  } else {
      printf("SUCCESS: Send and received file match!\n");
  }

  free(sendfile);
  free(recvfile);

  uart_finish();
}
