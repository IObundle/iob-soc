/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include "iob-axistream-in.h"

void iob_axis_in_reset() {
  IOB_AXISTREAM_IN_SET_SOFT_RESET(1);
  IOB_AXISTREAM_IN_SET_SOFT_RESET(0);
}

uint32_t iob_axis_read(uint32_t *value) {
  if (IOB_AXISTREAM_IN_GET_FIFO_EMPTY()) {
    return 0;
  } else {
    *value = IOB_AXISTREAM_IN_GET_DATA();
    return 1;
  }
}
