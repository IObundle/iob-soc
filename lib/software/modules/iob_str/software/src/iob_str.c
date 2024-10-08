/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <stdarg.h>
#include <stddef.h>

// copy src to dst and return number of copied chars (excluding '\0')
int iob_strcpy(char *dst, char *src) {
  if (dst == NULL || src == NULL) {
    return -1;
  }
  int cnt = 0;
  while (src[cnt] != 0) {
    dst[cnt] = src[cnt];
    cnt++;
  }
  dst[cnt] = '\0';
  return cnt;
}

// return 0 if equal, 1 if not equal
int iob_strcmp(char *str1, char *str2, int str_size) {
  int c = 0;
  while (c < str_size) {
    if (str1[c] != str2[c]) {
      return str1[c] - str2[c];
    }
    c++;
  }
  return 0;
}

// return string length
int iob_strlen(char *str) {
  int c = 0;
  while (str[c] != 0) {
    c++;
  }
  return c;
}

// concatenate src to dst up to max_len chars
// return concatenated string
char *iob_strncat(char *dst, char *src, int max_len) {
  int i = 0;
  int j = 0;

  while ((dst[i] != '\0')) {
    i++;
  }

  while ((src[j] != '\0') && (j < max_len)) {
    dst[i++] = src[j++];
  }
  dst[i] = '\0';

  return dst;
}
