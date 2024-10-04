/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "iob_timer.h"

int sysfs_read_file(const char *filename, uint32_t *read_value) {
  // Open file for read
  FILE *file = fopen(filename, "r");
  if (file == NULL) {
    perror("[User] Failed to open the file");
    return -1;
  }

  // Read uint32_t value from file in ASCII
  ssize_t ret = fscanf(file, "%u", read_value);
  if (ret == -1) {
    perror("[User] Failed to read from file");
    fclose(file);
    return -1;
  }

  fclose(file);

  return ret;
}

int sysfs_write_file(const char *filename, uint32_t write_value) {
  // Open file for write
  FILE *file = fopen(filename, "w");
  if (file == NULL) {
    perror("[User] Failed to open the file");
    return -1;
  }

  // Write uint32_t value to file in ASCII
  ssize_t ret = fprintf(file, "%u", write_value);
  if (ret == -1) {
    perror("[User] Failed to write to file");
    fclose(file);
    return -1;
  }

  fclose(file);

  return ret;
}

int timer_reset() {
  if (sysfs_write_file(IOB_TIMER_SYSFILE_RESET, 1) == -1) {
    return -1;
  }
  if (sysfs_write_file(IOB_TIMER_SYSFILE_RESET, 0) == -1) {
    return -1;
  }

  return 0;
}

int timer_init() {
  if (timer_reset()) {
    return -1;
  }

  if (sysfs_write_file(IOB_TIMER_SYSFILE_ENABLE, 1) == -1) {
    return -1;
  }

  return 0;
}

int timer_print_version() {
  uint32_t ret = -1;
  uint32_t version = 0;

  ret = sysfs_read_file(IOB_TIMER_SYSFILE_VERSION, &version);
  if (ret == -1) {
    return ret;
  }

  printf("[User] Version: 0x%x\n", version);
  return 0;
}

int timer_get_count(uint64_t *count) {
  uint32_t ret = -1;
  uint32_t data = 0;

  // Sample timer counter
  if (sysfs_write_file(IOB_TIMER_SYSFILE_SAMPLE, 1) == -1) {
    return -1;
  }
  if (sysfs_write_file(IOB_TIMER_SYSFILE_SAMPLE, 0) == -1) {
    return -1;
  }

  // Read sampled timer counter
  ret = sysfs_read_file(IOB_TIMER_SYSFILE_DATA_HIGH, &data);
  if (ret == -1) {
    return -1;
  }
  *count = ((uint64_t)data) << IOB_TIMER_DATA_LOW_W;
  ret = sysfs_read_file(IOB_TIMER_SYSFILE_DATA_LOW, &data);
  if (ret == -1) {
    return -1;
  }
  (*count) = (*count) | (uint64_t)data;

  return 0;
}

int main(int argc, char *argv[]) {
  printf("[User] IOb-Timer application\n");

  if (timer_init()) {
    perror("[User] Failed to initialize timer");

    return EXIT_FAILURE;
  }

  if (timer_print_version()) {
    perror("[User] Failed to print version");

    return EXIT_FAILURE;
  }

  // read current timer count
  uint64_t elapsed = 0;
  if (timer_get_count(&elapsed)) {
    perror("[User] Failed to get count");
  }
  printf("\nExecution time: %lu clock cycles\n", elapsed);

  return EXIT_SUCCESS;
}
