#include <stdbool.h>

#include "iob_axistream_in_swreg.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address);

//Get value from FIFO
uint32_t axistream_in_pop_word();
bool axistream_in_pop(uint8_t *byte_array, uint8_t *n_valid_bytes);

//Signal when FIFO empty
bool axistream_in_empty();

//Returns if last value of FIFO was the end of frame (by TLAST signal) and get rstrb from that value
bool axistream_in_was_last(char *rstrb);

//Soft reset
void axistream_in_reset();

void axistream_in_enable();
void axistream_in_disable();

//Set the FIFO threshold level
//If the FIFO level is equal or higher than the threshold, trigger an interrupt
void axistream_in_set_fifo_threshold(uint32_t threshold);

//Get current FIFO level
uint32_t axistream_in_fifo_level();
