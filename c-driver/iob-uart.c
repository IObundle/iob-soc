#include "iob-uart.h"

//base address
static int base;

//UART functions
void uart_init(int base_address, int div)
{
  base = base_address;

  MEMSET(base, UART_SOFT_RESET, 1);

  //Set the division factor div
  //div should be equal to round (fclk/baudrate)
  //E.g for fclk = 100 Mhz for a baudrate of 115200 we should uart_setdiv(868)
  MEMSET(base, UART_DIV, div);
}

int uart_get_write_wait()
{
  return(MEMGET(base, UART_WRITE_WAIT));
}

void uart_write_wait()
{
  while(MEMGET(base, UART_WRITE_WAIT));
}

int uart_getdiv()
{
  return (MEMGET(base, UART_DIV));
}

void uart_putc(char c)
{
  while(MEMGET(base, UART_WRITE_WAIT));
  MEMSET(base, UART_DATA, (int)c);
}

void uart_puts(const char *s)
{
  while (*s) uart_putc(*s++);
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
}

int uart_get_read_valid()
{
  return(MEMGET(base, UART_READ_VALID));
}

void uart_read_wait()
{
  while(!MEMGET(base, UART_READ_VALID));
}

int uart_getc()
{
  while(!MEMGET(base, UART_READ_VALID));
  return(MEMGET(base, UART_DATA));
}
