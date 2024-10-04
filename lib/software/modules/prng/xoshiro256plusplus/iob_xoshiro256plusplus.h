/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef H_IOB_XOSHIRO256PLUSPLUS_H
#define H_IOB_XOSHIRO256PLUSPLUS_H

#include <stdint.h>
#include <unistd.h>

void iob_xoshiro256_init(uint64_t seed);
uint64_t iob_xoshiro256_next(void);
ssize_t iob_getrandom(void *buffer, size_t length, unsigned int flags);
#endif // H_IOB_XOSHIRO256PLUSPLUS_H
