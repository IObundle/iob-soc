/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef H_IOB_TASKS_H
#define H_IOB_TASKS_H

#include "bsp.h"
#include <verilated.h>

#ifndef CLK_PERIOD
#define CLK_PERIOD 1000000000 / FREQ // 1/100MHz*10^9 = 10 ns
#endif

typedef enum { UINT, USINT, UCHAR } signal_datatype_t;

// Struct defining iob-native interface
typedef struct {
  unsigned char *iob_valid;
  void *iob_addr;
  signal_datatype_t iob_addr_type;
  unsigned int *iob_wdata;
  unsigned char *iob_wstrb;
  unsigned int *iob_rdata;
  unsigned char *iob_rvalid;
  unsigned char *iob_ready;
} iob_native_t;

typedef struct {
  unsigned char *clk;
  void (*eval)(void);
  void (*dump)(vluint64_t);
} timer_settings_t;

void Timer(unsigned int ns);
void iob_write(unsigned int cpu_address, unsigned int cpu_data,
               unsigned int nbytes, iob_native_t *native_if);
unsigned int iob_read(unsigned int cpu_address, iob_native_t *native_if);

#endif // H_IOB_TASKS_H
