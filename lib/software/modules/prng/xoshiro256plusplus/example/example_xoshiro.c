/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <stdio.h>
#include <stdlib.h>

#include "iob_xoshiro256plusplus.h"

#define N_GEN (10)

int main(int argc, char *argv[]) {
  printf("xoshiro PRNG test\n");
  int i = 0;
  for (i = 0; i < argc; i++) {
    printf("%s\n", argv[i]);
  }

  // a random 64 bit seed
  uint64_t seed = 0x010044e8f1c678ee;

  iob_xoshiro256_init(seed);

  printf("xoshiro PRNG sequence:\n");
  for (i = 0; i < (N_GEN / 8 + 1); i++) {
    printf("\t%d:%lx\n", i, iob_xoshiro256_next());
  }

  iob_xoshiro256_init(seed);
  uint8_t values[N_GEN] = {0};

  iob_getrandom(values, N_GEN, 0);

  printf("get random values:\n");
  for (i = 0; i < N_GEN; i++) {
    printf("\t%d:%x\n", i, values[i]);
  }

  return 0;
}
