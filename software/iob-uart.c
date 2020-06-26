#include "iob-uart.h"

void uart_puts(const char *s) {
  while (*s) uart_putc(*s++);
  uart_txwait();
}

void uart_printf(const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);

  const char *w = fmt;

  char c;

  static char v_char;
  static char buffer [512];
  static unsigned long v;
  static unsigned long digit;
  static int digit_shift;
  static char hex_a = 'a';

  while ((c = *w++) != '\0') {
    if (c != '%') {
      /* Regular character */
      uart_putc(c);
    }
    else {
      /* Format Escape Character */
      if ((c = *w++) != '\0') {
        switch (c) {
        case '%': // %%
          uart_putc(c);
          break;
        case 'c': // %c
          v_char = (char) va_arg(args, int);
          uart_putc(v_char);
          break;
        case 'X': // %X
          hex_a = 'A';  // Capital "%x"
        case 'x': // %x
          /* Process hexadecimal number format. */
          v = va_arg(args, unsigned long);

          /* If the number value is zero, just print and continue. */
          if (v == 0)
            {
              uart_putc('0');
              continue;
            }

          /* Find first non-zero digit. */
          digit_shift = 28;
          while (!(v & (0xF << digit_shift))) {
            digit_shift -= 4;
          }

          /* Print digits. */
          for (; digit_shift >= 0; digit_shift -= 4)
            {
              digit = (v & (0xF << digit_shift)) >> digit_shift;
              if (digit <= 9) {
                c = '0' + digit;
              }
              else {
                c = hex_a + digit - 10;
              }
              uart_putc(c);
            }

          /* Reset the A character */
          hex_a = 'a';
          break;
        case 's': // %s
          uart_puts(va_arg(args, char *));
          break;
          /* %d: print out an int         */
        case 'd':
          v = va_arg(args, unsigned long);
	  itoa(v, buffer, 10);
	  uart_puts(buffer);
          break;	
        default:
          /* Unsupported format character! */
          break;
        }
      }
      else {
        /* String ends with "...%" */
        /* This should be an error ??? */
        break;
      }
    }
  }
  va_end(args);
  uart_txwait();
}


unsigned int uart_getfile(char *mem) {

  uart_puts ("Receiving and loading file...\n\n");
  uart_endtext(); //free host from text mode

  // Get file size
  unsigned int file_size = (unsigned int) uart_getc();
  file_size |= ((unsigned int) uart_getc()) << 8;
  file_size |= ((unsigned int) uart_getc()) << 16;
  file_size |= ((unsigned int) uart_getc()) << 24;
  
  // Write file to main memory
  for (unsigned int i = 0; i < file_size; i++) {
    mem[i] = uart_getc();
  }

  uart_starttext();
  uart_printf("File received (%d bytes)\n", file_size);
  uart_endtext(); //free host from text mode
  uart_rxwait(); //wait for next command
  uart_starttext(); //renable host text mode for next mesg 
  return file_size;
}

void uart_sendfile(unsigned int file_size, char *mem) {

  uart_printf("Sending file (%d bytes)\n", file_size);
  uart_endtext();

  // send file size
  uart_putc((char)(file_size & 0x0ff));
  uart_putc((char)((file_size & 0x0ff00) >> 8));
  uart_putc((char)((file_size & 0x0ff0000) >> 16));
  uart_putc((char)((file_size & 0x0ff000000) >> 24));
  
  // send file contents
  for (unsigned int i = 0; i < file_size; i++) {
    uart_putc(mem[i]);
  }

  uart_starttext();
  uart_printf("File sent (%d bytes)\n", file_size);
  uart_endtext(); //free host from text mode
  uart_rxwait(); //wait for next command
  uart_starttext(); //renable host text mode for next mesg 
}

void uart_connect() {
  char host_resp;

  do {
    uart_putc(ENQ);
    host_resp = uart_getc();
  } while(host_resp != ACK);

  uart_starttext();
}


