#include "iob-axistream-out.h"
#include "printf.h"
#include <stdlib.h>

//Struct to store state of each peripheral instance
typedef struct {
	int address; //Address of peripheral instance
	uint8_t tdata_w; //TDATA signal width in bytes 
} instance_t;

//Global vars
instance_t *instances = NULL; //Array with state of each peripheral instance
unsigned int current_instance_idx; //Number of instances in 'instances' array
int n_instances = 0; //Number of instances in 'instances' array

//Set AXISTREAMOUT base address and TDATA width (in bytes)
void axistream_out_init(int base_address, uint8_t tdata_w){
  IOB_AXISTREAM_OUT_INIT_BASEADDR(base_address);

  //Check if instance with this base_address has already been initialized
  for (unsigned int i = 0; i < n_instances; i++) {
    if (instances[i].address == base_address) {
      current_instance_idx = i; // Save index of current instance for usage by other functions
      return;
    }
  }

  n_instances++;
  //Instance was not initialized, so initialize it
  instances = (instance_t *)realloc(instances, (++n_instances) * sizeof(instance_t));
  current_instance_idx = n_instances - 1; // Save index of current instance for usage by other functions
  instances[current_instance_idx].address = base_address;
  instances[current_instance_idx].tdata_w = tdata_w;
}

//Free memory from initialized instances
void axistream_out_free(){
	free(instances);
}

// Push data into the core with the correct wstrb and last.
// Arguments:
//     uint32_t data: data to insert in fifo
//     uint8_t n_valid_words: number of valid words in data (1 to 4)
//     is_last: if this is the last transfer of the frame
void axistream_out_push(uint32_t data, uint8_t n_valid_words,
                        uint8_t is_tlast) {
  uint8_t wstrb;

  if (instances[current_instance_idx].tdata_w == 1) {
    if (n_valid_words == 1)
      wstrb = 0x1;
    else if (n_valid_words == 2)
      wstrb = 0x3;
    else if (n_valid_words == 3)
      wstrb = 0x7;
    else if (n_valid_words == 4)
      wstrb = 0xf;
    else {
      printf("ERROR: tdata_w is 8 bits, so n_valid_words must be 1, 2, 3 or 4\n");
      return;
    }
  } else if (instances[current_instance_idx].tdata_w == 2) {
    if (n_valid_words == 1)
      wstrb = 0x3;
    else if (n_valid_words == 2)
      wstrb = 0xf;
    else {
      printf("ERROR: tdata_w is 16 bits, so n_valid_words must be 1 or 2\n");
      return;
    }
  } else if (instances[current_instance_idx].tdata_w == 4) {
    if (n_valid_words == 1)
      wstrb = 0xf;
    else {
      printf("ERROR: tdata_w is 32 bits, so n_valid_words must be 1\n");
      return;
    }
  } else {
    printf("ERROR: tdata_w must be 1, 2 or 4 bytes\n");
    return;
  }

  IOB_AXISTREAM_OUT_SET_WSTRB(wstrb);
  IOB_AXISTREAM_OUT_SET_LAST(is_tlast);
  // wstrb and last must be set before data, since the data triggers the transfer
  IOB_AXISTREAM_OUT_SET_DATA(data);
}

//Signal when FIFO is full
uint8_t axistream_out_full() { return IOB_AXISTREAM_OUT_GET_FULL(); }

//pulse soft reset
void axistream_out_reset(){
  IOB_AXISTREAM_OUT_SET_SOFT_RESET(1);
  IOB_AXISTREAM_OUT_SET_SOFT_RESET(0);
}

//Enable peripheral
void axistream_out_enable(){
  IOB_AXISTREAM_OUT_SET_ENABLE(1);
}

//Disable peripheral, preventing new transfers
void axistream_out_disable(){
  IOB_AXISTREAM_OUT_SET_ENABLE(0);
}

//Set the FIFO threshold level
//If the FIFO level is equal or lower than the threshold, trigger an interrupt
void axistream_out_set_fifo_threshold(uint32_t threshold){
  IOB_AXISTREAM_OUT_SET_FIFO_THRESHOLD(threshold);
}

//Get current FIFO level
uint32_t axistream_out_fifo_level(){
  return IOB_AXISTREAM_OUT_GET_FIFO_LEVEL();
}
