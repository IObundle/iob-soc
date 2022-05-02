#include "iob-axistream-in.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address){
  AXISTREAMIN_INIT_BASEADDR(base_address);
}

//Get value from FIFO (returns true if this is last byte from stream)
bool axistream_in_pop(char *returnValue){
  uint16_t value = AXISTREAMIN_GET_OUT();
  *returnValue = (char)value;
  return value & 0x100;
}

//Signal when FIFO empty
bool axistream_in_empty(){
  return AXISTREAMIN_GET_EMPTY();
}
