#ifndef H_UART_PC_EMUL_PLATFORM_H
#define H_UART_PC_EMUL_PLATFORM_H
/* PC Emulation of UART peripheral */

#ifdef PC

#include <bits/stdint-intn.h>
#include <stdint.h>
#include <stdio.h>

#include "iob_uart_swreg.h"
#include "iob-lib.h"

static UART_DIV_TYPE div_value;

static void uart_set_softreset(int64_t value) {
    //manage files to communicate with console here
    FILE *cnsl2soc_fd;

    while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL);
    fclose(cnsl2soc_fd);

    div_value=0;
    return;
}

static void uart_set_div(int64_t value) {
    div_value = (UART_DIV_TYPE) value;
    return;
}

static void uart_set_txdata(int64_t value) {
    // send byte to console
    char aux_char;
    UART_TXDATA_TYPE c = (UART_TXDATA_TYPE) value;
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

static void uart_set_txen(int64_t value) {
    return;
}

static void uart_set_rxen(int64_t value) {
    return;
}

static int64_t uart_get_txready() {
    return 1;
}

static int64_t uart_get_rxdata() {
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

static int64_t uart_get_rxready() {
    return 1;
}

static void io_set_int(int addr, int64_t value) {
    switch(addr){
        case UART_SOFTRESET:
            uart_set_softreset(value);
            break;
        case UART_DIV:
            uart_set_div(value);
            break;
        case UART_TXDATA:
            uart_set_txdata(value);
            break;
        case UART_TXEN:
            uart_set_txen(value);
            break;
        case UART_RXEN:
            uart_set_rxen(value);
            break;
        default:
            // unassigned addr, do nothing
            break;
    }
    return;
}
static int64_t io_get_int(int addr) {
    int64_t ret_val;
    switch(addr) {
        case UART_TXREADY:
            ret_val = uart_get_txready();
            break;
        case UART_RXDATA:
            ret_val = uart_get_rxdata();
            break;
        case UART_RXREADY:
            ret_val = uart_get_rxready();
            break;
        default:
            ret_val = -1;
            break;
    }
    return ret_val;
}

#endif // ifdef PC

#endif //ifndef H_UART_PC_EMUL_PLATFORM_H
