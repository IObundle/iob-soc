/* PC Emulation of UART peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_uart_swreg.h"
#include "iob_uart_swreg_pc_emul.h"

static uint8_t div_value;

void pc_emul_set_uart_softreset(int64_t value) {
    //manage files to communicate with console here
    FILE *cnsl2soc_fd;

    while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL);
    fclose(cnsl2soc_fd);

    div_value=0;
    return;
}

void pc_emul_set_uart_div(int64_t value) {
    div_value = (UART_DIV_TYPE) value;
    return;
}

void pc_emul_set_uart_txdata(int64_t value) {
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

void pc_emul_set_uart_txen(int64_t value) {
    return;
}

void pc_emul_set_uart_rxen(int64_t value) {
    return;
}

int64_t pc_emul_get_uart_txready() {
    return 1;
}

int64_t pc_emul_get_uart_rxdata() {
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

int64_t pc_emul_get_uart_rxready() {
    return 1;
}
