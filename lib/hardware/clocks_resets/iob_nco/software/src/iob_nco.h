/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#pragma once
#include "iob_nco_csrs.h"
#include <stdbool.h>

// Functions
void nco_reset();
void nco_init(uint32_t base_address);
void nco_enable(bool enable);
void nco_set_period(uint32_t period);
