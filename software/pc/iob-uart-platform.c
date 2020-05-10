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

void uart_putc(char c) {
  putc(c, stdout);
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
