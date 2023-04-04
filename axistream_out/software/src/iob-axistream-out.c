#include <stdlib.h>
#include "iob-axistream-out.h"

//Struct to store state of each peripheral instance
typedef struct {
	int address; //Address of peripheral instance
	uint8_t buffer[4]; //Buffer each of the 4 bytes to place in FIFO
	uint8_t n_valid_bytes; //Number of current valid bytes
	uint8_t tdata_w; //TDATA signal width in bytes 
} instance_t;

//Global vars
instance_t *instances = NULL; //Array with state of each peripheral instance
unsigned int current_instance_idx; //Number of instances in 'instances' array


//Set AXISTREAMOUT base address
//If instance has tdata_w > 1 byte, dont use this function to initialize it. Use function: axistream_out_init_tdata_w()
void axistream_out_init(int base_address){
  static int num_of_stored_instances = 0;
  IOB_AXISTREAM_OUT_INIT_BASEADDR(base_address);

  //Check if instance with this base_address has already been initialized
  for(unsigned int i = 0; i<num_of_stored_instances; i++){
    if(instances[num_of_stored_instances].address == base_address){
		 current_instance_idx = i; //Save index of current instance for usage by other functions
		 return;
	 } 
  }

  //Instance was not initialized, so initialize it
  instances = (instance_t *) realloc(instances, (++num_of_stored_instances)*sizeof(instance_t));
  current_instance_idx = num_of_stored_instances-1; //Save index of current instance for usage by other functions
  instances[current_instance_idx].address = base_address;
  instances[current_instance_idx].n_valid_bytes = 0;
  instances[current_instance_idx].tdata_w = 1; //Default tdata width to 1 byte
}

//Set AXISTREAMOUT base address and tdata width
void axistream_out_init_tdata_w(int base_address, int tdata_w){
  axistream_out_init(base_address);
  instances[current_instance_idx].tdata_w = tdata_w;
}

//Free memory from initialized instances
void axistream_out_free(){
	free(instances);
	instances = NULL;
}

//Place value in FIFO, also place wstrb for word with TLAST signal.
//If tlast_wstrb is zero then all bytes are valid and dont send TLAST signal
//tlast_wstrb has 1 up to 4 bits depending on the output width of the FIFO (width of TDATA signal). 
//If TDATA has 8 bits, then tlast_wstrb has 4 bits (1 for each valid byte of the last 32bit word in FIFO);
//If TDATA has 16 bits, then tlast_wstrb has 2 bits (1 for each valid 16 bit word of the last 32bit word in FIFO);
//If TDATA has 32 bits, then tlast_wstrb has 1 bits (in this case, 32 bits are always valid independently of tlast_wstrb, this bit only selects if we send TLAST signal)
void axistream_out_push_word(uint32_t value, char tlast_wstrb){
  if(tlast_wstrb)
     IOB_AXISTREAM_OUT_SET_WSTRB_NEXT_WORD_LAST(tlast_wstrb);
  //Set FIFO input value
  IOB_AXISTREAM_OUT_SET_IN(value);
}

//Place value in FIFO, also place wstrb for word with TLAST signal.
//Arguments:
//    byte_array: bytes to insert in fifo
//    n_valid_bytes: number of valid bytes in value, should be multiple of tdata_w
//    is_tlast: if value contains tlast
void axistream_out_push(uint8_t *byte_array, uint8_t n_valid_bytes, bool is_tlast){
  for(unsigned int i = 0; i<n_valid_bytes; i++){
    //Insert each byte of byte_array into buffer
    instances[current_instance_idx].buffer[instances[current_instance_idx].n_valid_bytes++]=byte_array[i];
	 
    //If buffer is full, push word into fifo
    if(instances[current_instance_idx].n_valid_bytes==4){
      //If this word contains tlast, and already placed all bytes of byte_array into buffer
      if(is_tlast && i==n_valid_bytes-1)
        IOB_AXISTREAM_OUT_SET_WSTRB_NEXT_WORD_LAST(0xf); //send tlast with all valid bytes
		//push buffer word into fifo
      IOB_AXISTREAM_OUT_SET_IN(*((uint32_t *)(void *)(instances[current_instance_idx].buffer)));
      instances[current_instance_idx].n_valid_bytes=0;
	 }
  }

  //If this is the tlast word, and there are some valid bytes (buffer is not empty) (not all bytes are valid, otherwise word would have already been sent) 
  if(is_tlast && instances[current_instance_idx].n_valid_bytes){
    //Find correct wstrb based on tdata_w and number of valid bytes
    uint8_t wstrb = instances[current_instance_idx].tdata_w==1 ? (n_valid_bytes==1 ? 0x1 : n_valid_bytes==2 ? 0x3 : 0x7) : //tdata_w is 1 byte, so wstrb can be: 'b0001, 'b0011, 'b0111
                    0x3; //tdata_w is 2 bytes, so wstrb can only be: 'b0011
    IOB_AXISTREAM_OUT_SET_WSTRB_NEXT_WORD_LAST(wstrb);
    IOB_AXISTREAM_OUT_SET_IN(*((uint32_t *)(void *)(instances[current_instance_idx].buffer)));
    instances[current_instance_idx].n_valid_bytes=0;
  }
}

//Signal when FIFO is full
bool axistream_out_full(){
  return IOB_AXISTREAM_OUT_GET_FULL();
}
