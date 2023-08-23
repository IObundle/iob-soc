#include "iob_axistream_in_swreg.h"

//AXISTREAMIN functions

//Set AXISTREAMIN base address
void axistream_in_init(int base_address);

// Get value from FIFO
// Returns a 32 bits word (check rstrb to know which bytes are valid)
// Arguments:
//     uint8_t *rstrb: pointer to a uint8_t where the valid bytes will be marked
//     with 1s (e.g. 0b00001111 means that the first 4 bytes are valid)
//     uint8_t *tlast:  pointer to a uint8_t where the tlast signal will be
//     stored
uint32_t axistream_in_pop(uint8_t *rstrb, uint8_t *tlast);

// Signal when FIFO empty
uint8_t axistream_in_empty();

// Soft reset
void axistream_in_reset();

void axistream_in_enable();
void axistream_in_disable();
