#pragma once
#include "iob_nco_swreg.h"

// Functions
void nco_reset();
void nco_init(uint32_t base_address);
uint64_t nco_get_count();
