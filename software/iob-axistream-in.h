#include <stdbool.h>

#include "iob_axistream_in_swreg.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address);

//Get value from FIFO (returns true if this is last byte from stream)
bool axistream_in_pop(char *returnValue);

//Signal when FIFO empty
bool axistream_in_empty();

