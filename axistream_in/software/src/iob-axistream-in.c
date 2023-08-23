#include "iob-axistream-in.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address){
  IOB_AXISTREAM_IN_INIT_BASEADDR(base_address);
}

// Get value from FIFO
// Returns a 32 bits word (check rstrb to know which bytes are valid)
// Arguments:
//     uint8_t *rstrb: pointer to a uint8_t where the valid bytes will be marked
//     with 1s (e.g. 0b00001111 means that the first 4 bytes are valid)
//     uint8_t *tlast:  pointer to a uint8_t where the tlast signal will be stored
uint32_t axistream_in_pop(uint8_t *rstrb, uint8_t *tlast){
  // Data must be read before tlast and rstrb to assert these signals accordingly
  uint32_t data = IOB_AXISTREAM_IN_GET_DATA();
  *rstrb = IOB_AXISTREAM_IN_GET_RSTRB();
  *tlast = IOB_AXISTREAM_IN_GET_LAST();
  return data;
}

//Signal when FIFO empty
uint8_t axistream_in_empty() {
  return IOB_AXISTREAM_IN_GET_EMPTY(); 
}

//pulse soft reset
void axistream_in_reset(){
  IOB_AXISTREAM_IN_SET_SOFT_RESET(1);
  IOB_AXISTREAM_IN_SET_SOFT_RESET(0);
}

//Enable peripheral
void axistream_in_enable(){
  IOB_AXISTREAM_IN_SET_ENABLE(1);
}

//Disable tready signal, preventing new transfers
void axistream_in_disable(){
  IOB_AXISTREAM_IN_SET_ENABLE(0);
}
