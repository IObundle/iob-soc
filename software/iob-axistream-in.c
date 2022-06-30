#include "iob-axistream-in.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address){
  IOB_AXISTREAM_IN_INIT_BASEADDR(base_address);
}

//Get value from FIFO
uint32_t axistream_in_pop(){
  return IOB_AXISTREAM_IN_GET_OUT(0);
}

//Signal when FIFO empty
bool axistream_in_empty(){
  return IOB_AXISTREAM_IN_GET_EMPTY();
}

//Returns if last value of FIFO was the end of frame (by TLAST signal) and get rstrb from that value
//If this function returns False, then all bytes from last value of FIFO are valid and the value of rstrb is always 1111.
//rstrb has 4 bits, one for each valid byte of the last 32 bit word in FIFO.
//The possible values of rstrb depend on the FIFO input width (TDATA signal width):
//If TDATA has 8 bits, then rstrb can have values: 0001, 0011, 0111, 1111
//If TDATA has 16 bits, then rstrb can have values: 0011, 1111
//If TDATA has 32 bits, then rstrb can only have value: 1111
bool axistream_in_was_last(char *rstrb){
  uint16_t value = IOB_AXISTREAM_IN_GET_LAST();
  *rstrb = (char)value & 0xf;
  return value & 0x10;
}
