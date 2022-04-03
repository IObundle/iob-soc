#include "iob-uart.h"
#include <stdio.h>

//base address
static int base;
static int div_value;

//UART functions

void uart_setbaseaddr(int v)
{
  //manage files to communicate with console here
  FILE *cnsl2soc_fd;

  while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL);
  fclose(cnsl2soc_fd);
  return;
}

void uart_softrst(uint8_t v)
{
  div_value=0;
  return;
}

void uart_setdiv(uint16_t div)
{
  div_value = div;
  return;
}

//tx functions
void uart_txen(uint8_t v) {
  return;
}

void uart_txwait() {
  return;
}

uint8_t uart_istxready(){
  return 1;
}

void uart_putc(char c) {
  // send byte to console
  char aux_char;
  int able2read;
  FILE *soc2cnsl_fd;

  while(1){
    if((soc2cnsl_fd = fopen("./soc2cnsl", "rb")) != NULL){
      able2read = fread(&aux_char, sizeof(char), 1, soc2cnsl_fd);
      if(able2read == 0){
        fclose(soc2cnsl_fd);
        soc2cnsl_fd = fopen("./soc2cnsl", "wb");
        fwrite(&c, sizeof(char), 1, soc2cnsl_fd);
        fclose(soc2cnsl_fd);
        break;
      }
      fclose(soc2cnsl_fd);
    }
  }
}

//rx functions
void uart_rxen(uint8_t v) {
  return;
}

void uart_rxwait(){
  return;
}

uint8_t uart_rxisready(){
  return 1;
}

char uart_getc() {
  //get byte from console
  char c;
  int able2write;
  FILE *cnsl2soc_fd;

  while(1){
    if ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL){
      break;
    }
    able2write = fread(&c, sizeof(char), 1, cnsl2soc_fd);
    if (able2write > 0){
      fclose(cnsl2soc_fd);
      cnsl2soc_fd = fopen("./cnsl2soc", "w");
      fclose(cnsl2soc_fd);
      break;
    }
    fclose(cnsl2soc_fd);
  }
  return c;
}
