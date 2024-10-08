/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>

#include "iob_uart_csrs.h"

#define UART_PROGNAME "IOb-UART"

// UART commands
#define STX 2 // start text
#define ETX 3 // end text
#define EOT 4 // end of transission
#define ENQ 5 // enquiry
#define ACK 6 // acklowledge
#define FTX 7 // transmit file
#define FRX 8 // receive file

// UART functions

// Reset UART and set the division factor
void uart_init(int base_address, uint16_t div);

// Close transmission
void uart_finish();

// TX FUNCTIONS

// Enable / disable tx
void uart_txen(uint8_t val);

// Wait for tx to be ready
void uart_txwait();

// Print char
void uart_putc(char c);

// Print string
void uart_puts(const char *s);

// Send file
void uart_sendfile(char *file_name, int file_size, char *mem);

// RX FUNCTIONS

// Wait for rx to be ready
void uart_rxwait();

// Get char
uint8_t uart_getc();

// Receive file
uint32_t uart_recvfile(char *file_name, char *mem);
