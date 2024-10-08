/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* PC Emulation of nco peripheral */

#include <stdint.h>
#include <time.h>

#include "bsp.h"
#include "iob_nco_csrs.h"

/* convert clock values from PC CLOCK FREQ to EMBEDDED FREQ */
#define PC_TO_FREQ_FACTOR ((1.0 * FREQ) / CLOCKS_PER_SEC)

static clock_t start, end, time_counter, counter_reg;
static int nco_enable;

static int base;
void IOB_NCO_INIT_BASEADDR(uint32_t addr) {
  base = addr;
  return;
}

void IOB_NCO_SET_SOFTRESET(uint8_t value) {
  // use only reg width
  int rst_int = (value & 0x01);
  if (rst_int) {
    start = end = 0;
    time_counter = 0;
    nco_enable = 0;
  }
  return;
}

void IOB_NCO_SET_ENABLE(uint8_t value) {
  // use only reg width
  int en_int = (value & 0x01);
  // manage transitions
  // 0 -> 1
  if (nco_enable == 0 && en_int == 1) {
    // start counting time
    start = clock();
  } else if (nco_enable == 1 && en_int == 0) {
    // accumulate enable interval
    end = clock();
    nco_enable += (end - start);
    start = end = 0; // reset aux clock values
  }
  // store enable en_int
  nco_enable = en_int;
  return;
}
