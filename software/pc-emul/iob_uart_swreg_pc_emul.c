/* PC Emulation of UART peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_uart_swreg.h"

static uint16_t div_value;

void UART_INIT_BASEADDR(uint32_t addr) {
    base = addr;
    return;
}

void UART_SET_SOFTRESET(uint8_t value) {
    //manage files to communicate with console here
    FILE *cnsl2soc_fd;

    while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL);
    fclose(cnsl2soc_fd);

    div_value=0;
    return;
}

void UART_SET_DIV(uint16_t value) {
    div_value = value;
    return;
}

void UART_SET_TXDATA(uint8_t value) {
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
                fwrite(&value, sizeof(char), 1, soc2cnsl_fd);
                fclose(soc2cnsl_fd);
                break;
            }
            fclose(soc2cnsl_fd);
        }
    }
}

void UART_SET_TXEN(uint8_t value) {
    return;
}

void UART_SET_RXEN(uint8_t value) {
    return;
}

uint8_t UART_GET_TXREADY() {
    return 1;
}

uint8_t UART_GET_RXDATA() {
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
    return (int64_t) c;
}

uint8_t UART_GET_RXREADY() {
    return 1;
}
