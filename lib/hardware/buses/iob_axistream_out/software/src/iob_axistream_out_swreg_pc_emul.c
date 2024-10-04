/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* PC Emulation of axistream-out peripheral */

#include <stdint.h>

#include "iob_axistream_out_csrs.h"

// Base Address
static int base;
void IOB_AXISTREAM_OUT_INIT_BASEADDR(uint32_t addr) { base = addr; }

// Core Setters and Getters
void IOB_AXISTREAM_OUT_SET_DATA(uint32_t value) {}

uint8_t IOB_AXISTREAM_OUT_GET_FULL() { return 0x00; }

void IOB_AXISTREAM_OUT_SET_SOFT_RESET(uint8_t value) {}

void IOB_AXISTREAM_OUT_SET_ENABLE(uint8_t value) {}

void IOB_AXISTREAM_OUT_SET_WSTRB(uint8_t value) {}

void IOB_AXISTREAM_OUT_SET_LAST(uint8_t value) {}

void IOB_AXISTREAM_OUT_SET_FIFO_THRESHOLD(uint32_t value) {}

uint32_t IOB_AXISTREAM_OUT_GET_FIFO_LEVEL() { return 0x00; }

uint16_t IOB_AXISTREAM_OUT_GET_VERSION() { return 0xaaaa; }
