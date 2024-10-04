/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <stdbool.h>

#include "iob_gpio_csrs.h"

// GPIO functions

// Set GPIO base address
void gpio_init(int base_address);

// Get values from inputs
uint32_t gpio_get();

// Set values on outputs
void gpio_set(uint32_t outputs);

// Set mask for outputs (bits 1 are driven outputs, bits 0 are tristate)
void gpio_set_output_enable(uint32_t value);
