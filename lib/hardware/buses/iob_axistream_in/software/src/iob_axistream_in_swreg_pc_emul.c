/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* PC Emulation of axistream-in peripheral */

#include <stdint.h>

#include "iob_axistream_in_csrs.h"

// Base Address
static int base;
void IOB_AXISTREAM_IN_INIT_BASEADDR(uint32_t addr) { base = addr; }

// Core Setters and Getters
uint32_t IOB_AXISTREAM_IN_GET_DATA() { return 0x00; }

uint8_t IOB_AXISTREAM_IN_GET_EMPTY() { return 0x01; }

uint8_t IOB_AXISTREAM_IN_GET_TLAST_DETECTED() { return 0x00; }

uint32_t IOB_AXISTREAM_IN_GET_NWORDS() { return 0x00; }

void IOB_AXISTREAM_IN_SET_SOFT_RESET(uint8_t value) {}

void IOB_AXISTREAM_IN_SET_ENABLE(uint8_t value) {}

void IOB_AXISTREAM_IN_SET_FIFO_THRESHOLD(uint32_t value) {}

void IOB_AXISTREAM_IN_SET_MODE(uint8_t value) {}

uint32_t IOB_AXISTREAM_IN_GET_FIFO_LEVEL() { return 0x00; }

uint16_t IOB_AXISTREAM_IN_GET_VERSION() { return 0xaaaa; }
