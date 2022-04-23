/* PC Emulation of AXISTREAMIN peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_axistream_in_swreg.h"

static uint16_t div_value;

void AXISTREAMIN_INIT_BASEADDR(uint32_t addr) {
    base = addr;
    return;
}

//TODO
