#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "iob_gpio.h"

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

uint32_t gpio_get() {
  uint32_t value = 0;
  sysfs_read_file(IOB_GPIO_SYSFILE_GPIO_INPUT, &value);

  return value;
}

int gpio_set(uint32_t value) {
  return sysfs_write_file(IOB_GPIO_SYSFILE_GPIO_OUTPUT, value);
}

int gpio_set_output_enable(uint32_t value) {
  return sysfs_write_file(IOB_GPIO_SYSFILE_GPIO_OUTPUT_ENABLE, value);
}

int main() {
  printf("[User] IOb-GPIO test\n");

  if (gpio_print_version() == -1) {
    perror("[User] Failed to print version");

    return -1;
  }

  // read current timer count
  uint32_t value = 0;
  if (gpio_get(&value) == -1 || gpio_set_output_enable(0x0) == -1 ||
          gpio_set(0x0) == -1) {
    perror("[User] Failed to get/set outputs");

    return -1;
  }

  return 0;
}
