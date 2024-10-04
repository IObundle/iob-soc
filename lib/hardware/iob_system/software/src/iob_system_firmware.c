/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include "bsp.h"
#include "iob_system_conf.h"
#include "iob_system_periphs.h"
#include "iob_system_system.h"
#include "iob_timer.h"
#include "iob_uart.h"
#include "printf.h"
#include <string.h>

char *send_string = "Sending this string as a file to console.\n"
                    "The file is then requested back from console.\n"
                    "The sent file is compared to the received file to confirm "
                    "correct file transfer via UART using console.\n"
                    "Generating the file in the firmware creates an uniform "
                    "file transfer between pc-emul, simulation and fpga without"
                    " adding extra targets for file generation.\n";

int main() {
  char pass_string[] = "Test passed!";
  char fail_string[] = "Test failed!";

  // init timer
  timer_init(TIMER0_BASE);

  // init uart
  uart_init(UART0_BASE, FREQ / BAUD);
  printf_init(&uart_putc);

  // test puts
  uart_puts("\n\n\nHello world!\n\n\n");

  // test printf with floats
  printf("Value of Pi = %f\n\n", 3.1415);

  // test file send
  char *sendfile = malloc(1000);
  int send_file_size = 0;
  send_file_size = strlen(strcpy(sendfile, send_string));
  uart_sendfile("Sendfile.txt", send_file_size, sendfile);

  // test file receive
  char *recvfile = malloc(10000);
  int file_size = 0;
  file_size = uart_recvfile("Sendfile.txt", recvfile);

  // compare files
  if (strcmp(sendfile, recvfile)) {
    printf("FAILURE: Send and received file differ!\n");
  } else {
    printf("SUCCESS: Send and received file match!\n");
  }

  free(sendfile);
  free(recvfile);

  uart_sendfile("test.log", strlen(pass_string), pass_string);

  // read current timer count, compute elapsed time
  unsigned long long elapsed = timer_get_count();
  unsigned int elapsedu = elapsed / (FREQ / 1000000);

  printf("\nExecution time: %d clock cycles\n", (unsigned int)elapsed);
  printf("\nExecution time: %dus @%dMHz\n\n", elapsedu, FREQ / 1000000);

  uart_finish();
}
