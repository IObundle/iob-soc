/* PC Emulation of UART peripheral */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "iob_uart_swreg.h"

static uint16_t div_value;

static FILE *cnsl2soc_fd;
static FILE *soc2cnsl_fd;

void pc_emul_error(char *s) {
  printf("ERROR in iob-uart PC emulation: %s", s);
  exit(1);
}

static int base;
void IOB_UART_INIT_BASEADDR(uint32_t addr) {

  // wait for console to create communication files
  while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL)
    ;
  fclose(cnsl2soc_fd);
  while ((soc2cnsl_fd = fopen("./soc2cnsl", "rb")) == NULL)
    ;
  fclose(soc2cnsl_fd);

  base = addr;
  return;
}

void IOB_UART_SET_SOFTRESET(uint8_t value) {
  div_value = 0;
  return;
}

void IOB_UART_SET_DIV(uint16_t value) {
  div_value = value;
  return;
}

void IOB_UART_SET_TXDATA(uint8_t value) {
  // send byte to console
  char aux_char;
  int nbytes;

  while (1) {
    if ((soc2cnsl_fd = fopen("./soc2cnsl", "rb")) != NULL) {
      nbytes = fread(&aux_char, sizeof(char), 1, soc2cnsl_fd);
      if (nbytes == 0) {
        fclose(soc2cnsl_fd);
        soc2cnsl_fd = fopen("./soc2cnsl", "wb");
        fwrite(&value, sizeof(char), 1, soc2cnsl_fd);
        fclose(soc2cnsl_fd);
        break;
      }
      fclose(soc2cnsl_fd);
    }
  }
}

void IOB_UART_SET_TXEN(uint8_t value) { return; }

void IOB_UART_SET_RXEN(uint8_t value) { return; }

uint8_t IOB_UART_GET_TXREADY() { return 1; }

uint8_t IOB_UART_GET_RXDATA() {
  // get byte from console
  uint8_t c;
  int nbytes;

  while (1) {
    cnsl2soc_fd = fopen("./cnsl2soc", "rb");
    nbytes = fread(&c, sizeof(char), 1, cnsl2soc_fd);
    if (nbytes == 1) {
      fclose(cnsl2soc_fd);

      // the following removes file contents
      cnsl2soc_fd = fopen("./cnsl2soc", "wb");
      fclose(cnsl2soc_fd);

      break;
    }
    fclose(cnsl2soc_fd);
  }
  return c;
}

uint8_t IOB_UART_GET_RXREADY() { return 1; }
