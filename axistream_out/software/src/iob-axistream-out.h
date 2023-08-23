#include "iob_axistream_out_swreg.h"

//AXISTREAMOUT functions

//Set AXISTREAMOUT base address and TDATA width (in bytes)
void axistream_out_init(int base_address, uint8_t tdata_w);

// Push data into the core with the correct wstrb and last.
void axistream_out_push(uint32_t data, uint8_t n_valid_words, uint8_t is_last);

//Signal when FIFO is full
uint8_t axistream_out_full();

//Soft reset
void axistream_out_reset();

//Enable and disable AXISTREAMOUT
void axistream_out_enable();
void axistream_out_disable();
