/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* PC Emulation of GPIO peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_gpio_csrs.h"

static uint32_t base;
void IOB_GPIO_INIT_BASEADDR(uint32_t addr) { base = addr; }

// Core Setters and Getters
uint32_t IOB_GPIO_GET_GPIO_INPUT() { return 0xaaaaaaaa; }

void IOB_GPIO_SET_GPIO_OUTPUT(uint32_t value) {}

void IOB_GPIO_SET_GPIO_OUTPUT_ENABLE(uint32_t value) {}

uint16_t IOB_GPIO_GET_VERSION() { return 0xaaaa; }
