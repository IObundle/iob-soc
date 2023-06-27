/* PC Emulation of axistream-out peripheral */

#include <stdint.h>

#include "iob_axistream_out_swreg.h"


// Base Address
static int base;
void IOB_AXISTREAM_OUT_INIT_BASEADDR(uint32_t addr) {
  base = addr;
}

// Core Setters and Getters
void IOB_AXISTREAM_OUT_SET_IN(uint32_t value) {
}

uint8_t IOB_AXISTREAM_OUT_GET_FULL() {
  return 0x00;
}

void IOB_AXISTREAM_OUT_SET_SOFTRESET(uint8_t value) {
}

void IOB_AXISTREAM_OUT_SET_ENABLE(uint8_t value) {
}

void IOB_AXISTREAM_OUT_SET_WSTRB_NEXT_WORD_LAST(uint8_t value) {
}

uint16_t IOB_AXISTREAM_OUT_GET_VERSION() {
  return 0xaaaa;
}


