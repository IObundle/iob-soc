#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "uart.h"

#define UART_CLK_FREQ 200000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define CEILING(x,y) (((x) + (y) - 1) / (y))
//#define N 10 // number of memory writes/reads
#define Address_write 0x9004 //address where the writting starts

volatile int * vect;
volatile int   flag;

void main()
{ 
  int counter, reg = 0 ;
  unsigned char ledvar = 0;
  unsigned char Numb = 0;
  int N3, N2, N1, N0, N =0;

  //uart_reset();
  //  *((volatile int*) 0x1000000C) = 1;

  
  //uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  //uart_wait();  
 
  //print("... Initializing program in main memory:\n");
  //uart_puts("D\n");
  uart_write_wait();
  uart_puts("... Initializing program in main memory:\n");
  // uart_wait();
 
  vect = (volatile int*) Address_write;

  //print("Writting number at 0x");
  //print_hex(Address_write, 8);
  //uart_puts("W\n");
  uart_write_wait();
  uart_printf("Starting number writting at 0x%x\n", Address_write);
  // uart_wait(); 
 
  while(1){
    // print("\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n");
    uart_write_wait();
    uart_puts("\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n");
   
    // N = (int) Numb - 48;
    uart_write_wait();
    uart_puts ("N3 = ");
    uart_read_wait();
    Numb = uart_getc();
    if (Numb <= '9'){
      N3 =(int) Numb - 48;
    }else{
      N3 =(int) Numb - 87;
    }
   
   
    // print_hex (N3, 4);
    uart_write_wait();
    uart_printf("%x", N3);
    N3 = N3<<12;
   
    uart_write_wait();
    uart_puts("\nN2 = ");
    uart_read_wait();
    Numb = uart_getc();
   
    if (Numb <= '9'){
      N2 =(int) Numb - 48;
    }else{
      N2 =(int) Numb - 87;
    }
    //  print_hex (N2, 4);
    uart_write_wait();
    uart_printf("%x", N2);
    N2 = N2<<8;
   
    uart_write_wait();
    uart_puts ("\nN1 = ");
    uart_read_wait();
    Numb = uart_getc();
    if (Numb <= '9'){
      N1 =(int) Numb - 48;
    }else{
      N1 =(int) Numb - 87;
    }
    //print_hex (N1, 4);
    uart_write_wait();
    uart_printf("%x", N1);
    N1 = N1<<4;
    /*
      uart_puts ("\nN0 = ");
      Numb = getchar();
      if (Numb <= '9'){
      N0 =(int) Numb - 48;
      }else{
      N0 =(int) Numb - 87;
      }
      //print_hex (N0, 4);
      uart_printf("%x", N0);
   
      N = N3 + N2 + N1 + N0;
      //   print("\nN =");
      //print_hex (N, 4);
      uart_printf("\nN = %x\n", N);

      for (counter = 0; counter <= N; counter ++){
      vect[counter] = counter;
      };


      //print ("\nWrite verification:\n");
      //uart_puts("V\n");
      uart_puts("Write verification:\n");
      //  uart_wait();

      //flag =  105;
      //reg = vect[0]; //initialization-read
 
      for (counter = 0; counter <= N; counter ++){
      if(vect[counter] != counter)
      {
      //print_hex(vect[counter],5);
      //print(" should've been ");
      //print_hex(counter, 5);
      //print("\n");
      //flag = 26985;
      uart_printf("%x should've been ",vect[counter]); 
      //uart_wait();
      uart_printf("%x\n",counter); 
      //	uart_wait();
      };
      };

      //print ("Write print:\n");
      //uart_puts("P\n");
      uart_puts("Write print:\n");
      // uart_wait(); 

      for (counter = 0; counter <= N; counter ++)
      {
      //print(" ");
      //print_hex (vect[counter], 5);
      uart_printf("%x _ ",vect[counter]); 
      //uart_wait(); 
      };
  
      //print("\nEnd of program.\n");
      uart_puts("\nEnd of program.\n");
      //uart_wait(); 
      */
  }  
 
  //while (1);
}
