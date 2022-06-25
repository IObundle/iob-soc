#include <stdbool.h>

#include "iob_axistream_in_swreg.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address);

//Get value from FIFO
uint32_t axistream_in_pop();

//Signal when FIFO empty
bool axistream_in_empty();

//Returns if last value of FIFO was the end of frame (by TLAST signal) and get rstrb from that value
bool axistream_in_was_last(char *rstrb);
