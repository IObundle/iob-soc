/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#pragma once
#include "iob_timer_csrs.h"

// Functions
void timer_reset();
void timer_init(uint32_t base_address);
uint64_t timer_get_count();
