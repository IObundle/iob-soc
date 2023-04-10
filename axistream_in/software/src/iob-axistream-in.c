#include "iob-axistream-in.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address){
  IOB_AXISTREAM_IN_INIT_BASEADDR(base_address);
}

//Get value from FIFO
uint32_t axistream_in_pop_word(){
  return IOB_AXISTREAM_IN_GET_OUT(0);
}

//Get value from FIFO
//Returns true if this word was tlast, false otherwise
//Arguments:
//    byte_array: byte array to be filled with 4 bytes popped from fifo word
//    n_valid_bytes: Number of valid bytes in this word (will always be 4 if tlast is not active)
bool axistream_in_pop(uint8_t *byte_array, uint8_t *n_valid_bytes){
  uint32_t fifo_word = IOB_AXISTREAM_IN_GET_OUT(0);
  byte_array[0]= fifo_word & 0xff;
  byte_array[1]= fifo_word>>8 & 0xff;
  byte_array[2]= fifo_word>>16 & 0xff;
  byte_array[3]= fifo_word>>24 & 0xff;

  uint8_t value = IOB_AXISTREAM_IN_GET_LAST();
  if(!axistream_in_empty() && (value & 0x10)){ //This is tlast word
     //TODO: [Optimization] make register return number of valid bytes instead of rstrb (this removes need for counting here)
     value = value & 0xff; //Leave only rstrb
     for(*n_valid_bytes = 0; value; value>>1) //Count amount of valid bytes
       (*n_valid_bytes)++;
    return true;
  } else { 
    *n_valid_bytes = 4;
    return false;
  }
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
  uint8_t value = IOB_AXISTREAM_IN_GET_LAST();
  *rstrb = (char)value & 0xf;
  return value & 0x10;
}


//pulse soft reset
void axistream_in_reset(){
  IOB_AXISTREAM_IN_SET_SOFTRESET(1);
  IOB_AXISTREAM_IN_SET_SOFTRESET(0);
}
