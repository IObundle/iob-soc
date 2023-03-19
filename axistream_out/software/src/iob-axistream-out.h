#include <stdbool.h>

#include "iob_axistream_out_swreg.h"

//AXISTREAMOUT functions

//Set AXISTREAMOUT base address
void axistream_out_init(int base_address);
void axistream_out_init_tdata_w(int base_address, int tdata_w);

//Place value in FIFO, also place wstrb for word with TLAST signal.
void axistream_out_push_word(uint32_t value, char tlast_wstrb);
void axistream_out_push(uint8_t *byte_array, uint8_t n_valid_bytes, bool is_tlast);

//Signal when FIFO is full
bool axistream_out_full();

//Free memory from initialized instances
void axistream_out_free();
