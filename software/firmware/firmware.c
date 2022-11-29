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


  
  IOB_PCIE_INIT_BASEADDR(PCIE_BASE);

    
  

  
  

  long long rData [100];  


#ifndef SIM

 
  int rLen =  IOB_PCIE_GET_RXCHNL_LEN();
  
  for (int i = 0 ; i < 2 * rLen ; i++){
    rData[i] = IOB_PCIE_GET_RXCHNL_DATA();
    printf("data[%d]! %d \n",i, rData[i]);
    };

  
  IOB_PCIE_SET_TXCHNL_LEN(rLen);

  for (int i = 0 ; i < 2 * rLen ; i++){
    IOB_PCIE_SET_TXCHNL_DATA(rData[i]);
    printf("datasent[%d] \n",i);
  };
  


#else
  
  IOB_PCIE_SET_TXCHNL_LEN(20);

  for (int i = 0 ; i < 2 * 20 ; i++){
    IOB_PCIE_SET_TXCHNL_DATA(i);
    printf("datasent[%d] \n",i);
  };

#endif
  
  

#ifdef SIM
  
  int rLen =  IOB_PCIE_GET_RXCHNL_LEN();
  for (int i = 0 ; i < 2 * rLen ; i++){
    rData[i] = IOB_PCIE_GET_RXCHNL_DATA();
    printf("data[%d]! %d \n",i, rData[i]);
  };
#endif

  uart_finish();
}
