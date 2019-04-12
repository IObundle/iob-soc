#include "iob-uart.h"

#define MEMSET(base, location, value) (*((volatile int*) (base + (sizeof(int)) * location)) = value)
#define MEMGET(base, location)        (*((volatile int*) (base + (sizeof(int)) * location)))

//UART functions
void uart_setdiv(unsigned int base, int div)
{
    MEMSET(base, UART_DIV, div);
}

void uart_wait(unsigned int base)
{
  while(MEMGET(base, UART_WAIT));
}

int uart_getdiv(unsigned int base)
{
  return (MEMGET(base, UART_DIV));
}

void uart_putc(unsigned int base, char c)
{
  while(MEMGET(base, UART_WAIT));
  MEMSET(base, UART_DATAOUT, (int)c);
}

void uart_puts(const char *s)
{
  while (*s) uart_putc(*s++);
}

void uart_printf(const char* fmt, int var) {

  const char *w = fmt;
  char c;

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
      c = *w++;
      switch (c) {
      case '%': // %%
      case 'c': // %c
        uart_putc(c);
        break;
      case 'X': // %X
        hex_a = 'A';  // Capital "%x"
      case 'x': // %x
          /* Process hexadecimal number format. */
          /* If the number value is zero, just print and continue. */
          if (var == 0)
            {
              uart_putc('0');
              continue;
            }

          /* Find first non-zero digit. */
          digit_shift = 28;

          while (!(var & (0xF << digit_shift))) {
            digit_shift -= 4;
          }

          /* Print digits. */
          for (; digit_shift >= 0; digit_shift -= 4)
            {
              digit = (var & (0xF << digit_shift)) >> digit_shift;
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
        default:
          /* Unsupported format character! */
          break;
      }
    }
  }
}

