/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include "iob-axistream-out.h"

void iob_axis_out_reset() {
  IOB_AXISTREAM_OUT_SET_SOFT_RESET(1);
  IOB_AXISTREAM_OUT_SET_SOFT_RESET(0);
}

uint32_t iob_axis_write(uint32_t value) {
  if (IOB_AXISTREAM_OUT_GET_FIFO_FULL()) {
    return 0;
  } else {
    IOB_AXISTREAM_OUT_SET_DATA(value);
    return 1;
  }
}
