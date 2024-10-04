/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include "iob_timer.h"

// Base Address
static uint32_t base;

void timer_reset() {
  IOB_TIMER_SET_RESET(1);
  IOB_TIMER_SET_RESET(0);
}

void timer_init(uint32_t base_address) {
  base = base_address;
  IOB_TIMER_INIT_BASEADDR(base_address);
  timer_reset();
  IOB_TIMER_SET_ENABLE(1);
}

uint64_t timer_get_count() {
  // sample timer counter
  IOB_TIMER_SET_SAMPLE(1);
  IOB_TIMER_SET_SAMPLE(0);

  uint64_t count = (uint64_t)IOB_TIMER_GET_DATA_HIGH();
  count <<= IOB_TIMER_DATA_LOW_W;
  count |= (uint64_t)IOB_TIMER_GET_DATA_LOW();

  return count;
}
