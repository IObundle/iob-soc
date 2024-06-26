#pragma once
#include "iob_timer_swreg.h"

// Functions
void timer_reset();
void timer_init(uint32_t base_address);
uint64_t timer_get_count();
