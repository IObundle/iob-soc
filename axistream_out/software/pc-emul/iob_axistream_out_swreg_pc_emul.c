/* PC Emulation of AXISTREAMOUT peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_axistream_out_swreg.h"

static uint16_t div_value;

void AXISTREAMOUT_INIT_BASEADDR(uint32_t addr) {
    base = addr;
    return;
}

//TODO
