#include "iob-uart.h"
#include <stdio.h>

//base address
static int base;
static int div_value;

//UART functions
void uart_init(int base_address, int div) {
  //capture base address for good
  base = base_address;
  div_value = div;
}

int uart_getdiv()
{
  return div_value;
}

void uart_txwait() {
  return;
}

int uart_txstatus(){
  return 1;
}

void uart_putc(char c) {
  putc(c, stdout);
}

void uart_rxwait(){
  return;
}

int uart_rxstatus(){
  return 1;
}

char uart_getc() {
  return ( (char) getc(stdin));
}


// itoa() implementation - since it is not a C standard function
// adapted from http://www.strudel.org.uk/itoa/#newest
void itoa(int value, char* str, int base){
  //check for  2 <= base <= 16
  if(base < 2 || base > 16){
    str[0] = '\n';
    return;
  }

  //aux variables
  char *ptr = str, *ptr1 = str, tmp_char;
  int tmp_value;

  char* aux_str = "fedcba9876543210123456789abcdef";

  //get digits of value - from least significant to most significant
  do{
    tmp_value = value;
    //divide by base
    value /= base;
    //select correct digit
    *ptr++ = aux_str[15+ (tmp_value - value*base)];
  }while(value);

  //check for sign
  if(tmp_value < 0){
    *ptr++ = '-';
  }
  
  //terminate string and point to previous char
  *ptr-- = '\0';
  //invert string
  while(ptr1 < ptr){
    //swap chars
    tmp_char = *ptr;
    *ptr-- = *ptr1;
    *ptr1++ = tmp_char;
  }
  return;
}

// utoa() implementation - since it is not a C standard function
// adapted from https://searchcode.com/codesearch/view/20251583/

void utoa(int value, char *str, int base) {
    char temp[17];  //an int can only be 16 bits long
                    //at radix 2 (binary) the string
                    //is at most 16 + 1 null long.
    int i = 0;
    int digit;
    int j = 0;

    //construct a backward string of the number.
    do {
        digit = (uint32_t)value % base;
        if (digit < 10) 
            temp[i++] = digit + '0';
        else
            temp[i++] = digit - 10 + 'A';
         value  = (uint32_t)value/base;
    } while ((uint32_t)value > 0);

    i--;


    //now reverse the string.
    while ( i >=0 ) {// while there are still chars
        str[j++] = temp[i--];    
    }
    str[j] = 0; // add null termination.

    return;
}

