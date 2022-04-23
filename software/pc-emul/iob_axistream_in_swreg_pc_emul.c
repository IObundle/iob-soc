/* PC Emulation of AXISTREAMIN peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_axistream_in_swreg.h"

static uint16_t div_value;

void AXISTREAMIN_INIT_BASEADDR(uint32_t addr) {
    base = addr;
    return;
}

//Get value from FIFO (returns true if this is last byte from stream)
bool axistream_in_pop(char *returnValue){
  *returnValue = 0;
  return 1;
}

//Signal when FIFO empty
bool axistream_in_empty(){
  return 0;
}
