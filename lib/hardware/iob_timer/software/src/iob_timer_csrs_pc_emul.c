/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* PC Emulation of TIMER peripheral */

#include <stdint.h>
#include <time.h>

#include "bsp.h"
#include "iob_timer_csrs.h"

/* convert clock values from PC CLOCK FREQ to EMBEDDED FREQ */
#define PC_TO_FREQ_FACTOR ((1.0 * FREQ) / CLOCKS_PER_SEC)

static clock_t start, end, time_counter, counter_reg;
static int timer_enable;

static int base;
void IOB_TIMER_INIT_BASEADDR(uint32_t addr) {
  base = addr;
  return;
}

void IOB_TIMER_SET_RESET(uint8_t value) {
  // use only reg width
  int rst_int = (value & 0x01);
  if (rst_int) {
    start = end = 0;
    time_counter = 0;
    timer_enable = 0;
  }
  return;
}

void IOB_TIMER_SET_ENABLE(uint8_t value) {
  // use only reg width
  int en_int = (value & 0x01);
  // manage transitions
  // 0 -> 1
  if (timer_enable == 0 && en_int == 1) {
    // start counting time
    start = clock();
  } else if (timer_enable == 1 && en_int == 0) {
    // accumulate enable interval
    end = clock();
    timer_enable += (end - start);
    start = end = 0; // reset aux clock values
  }
  // store enable en_int
  timer_enable = en_int;
  return;
}

void IOB_TIMER_SET_SAMPLE(uint8_t value) {
  // use only reg width
  int sample_int = (value & 0x01);
  if (sample_int) {
    counter_reg = time_counter;
    if (start != 0)
      counter_reg += (clock() - start);
  }
  return;
}

uint32_t IOB_TIMER_GET_DATA_HIGH() {
  /* convert clock from PC CLOCKS_PER_CYCLE to FREQ */
  double counter_freq = (1.0 * counter_reg) * PC_TO_FREQ_FACTOR;
  return ((int)(((unsigned long long)counter_freq) >> 32));
}

uint32_t IOB_TIMER_GET_DATA_LOW() {
  /* convert clock from PC CLOCKS_PER_CYCLE to FREQ */
  double counter_freq = (1.0 * counter_reg) * PC_TO_FREQ_FACTOR;
  return ((int)(((unsigned long long)counter_freq) & 0xFFFFFFFF));
}
