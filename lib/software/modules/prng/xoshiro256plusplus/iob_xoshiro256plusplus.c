/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/*
 * Adapted from https://prng.di.unimi.it/xoshiro256plusplus.c
 * 64 bit PRNG
 *
 * Note: this PRNG is NOT cryptographically save. DO NOT use for cryptographic
 * applications.
 * Check:
 * https://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator
 * for more information.
 *
 */
#include "iob_xoshiro256plusplus.h"

static inline uint64_t rotl(const uint64_t x, int k) {
  return (x << k) | (x >> (64 - k));
}

static uint64_t s[4];

/*
 * Adapted from https://prng.di.unimi.it/splitmix64.c
 * xoshiro author advices using splitmix64 to initialize xoshiro PRNG
 * */
static uint64_t splitmix64_next(uint64_t splitmix64_state) {
  uint64_t z = (splitmix64_state += 0x9e3779b97f4a7c15);
  z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
  z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
  return z ^ (z >> 31);
}

/* initialize PRNG seed */
void iob_xoshiro256_init(uint64_t seed) {
  s[0] = splitmix64_next(seed);
  s[1] = splitmix64_next(s[0]);
  s[2] = splitmix64_next(s[1]);
  s[3] = splitmix64_next(s[2]);
  return;
}

uint64_t iob_xoshiro256_next(void) {
  const uint64_t result = rotl(s[0] + s[3], 23) + s[0];

  const uint64_t t = s[1] << 17;

  s[2] ^= s[0];
  s[3] ^= s[1];
  s[1] ^= s[2];
  s[0] ^= s[3];

  s[2] ^= t;

  s[3] = rotl(s[3], 45);

  return result;
}

/* Write LENGTH bytes of randomness starting at BUFFER. Return the number of
   bytes written, or -1 on error.
   Use this method to replace getrandom() in environments without Linux OS.
*/
ssize_t iob_getrandom(void *buffer, size_t length, unsigned int flags) {
  size_t bytes_to_get = length;
  size_t ptr = 0;
  uint64_t random_8bytes = 0;
  int byte_cnt = 0;

  while (bytes_to_get-- > 0) {
    if (byte_cnt == 0) {
      random_8bytes = iob_xoshiro256_next();
      byte_cnt = 8;
    }
    ((uint8_t *)buffer)[ptr++] = (uint8_t)(random_8bytes & 0x0FF);
    random_8bytes >>= 8;
    byte_cnt--;
  }
  return (flags != 0) ? (ssize_t)-1 : (ssize_t)length;
}
