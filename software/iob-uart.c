#include "stdint.h"
#include "iob-uart.h"

#define PROGNAME "IOb-UART"

void uart_puts(char *s) {
  while (*s) uart_putc(*s++);
  uart_txwait();
}

void uart_printf(const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);

  const char *w = fmt;

  char c;

  char v_char;
  char buffer [512];
  uint32_t v;
  uint32_t digit;
  int digit_shift;
  char hex_a = 'a';
#ifdef LONGLONG
  uint64_t vlong;
#endif
#ifdef FLOAT
  float vfloat;
#endif

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
          v = va_arg(args, uint32_t);

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
          v = va_arg(args, uint32_t);
	  uart_itoa(v, buffer, 10);
	  uart_puts(buffer);
          break;
        case 'u':
          v = va_arg(args, uint32_t);
          if (v >= (1<<31)) {
            uart_printf("%d%d", (int)(v/10), (int)(v%10));
          } else {
            uart_printf("%d",v);
          }
          break;
#ifdef LONGLONG
        case 'l':
          if ((c = *w++) == 'l') {
            vlong = va_arg(args, uint64_t);
            if ((c = *w++) == 'u'|| c == 'd') {
              if (c == 'd' && vlong >= ((uint64_t)1<<63)) {
                vlong ^= ~0;
                vlong++;
                uart_printf("-");
              }
              if (vlong >= ((uint64_t)1<<32)) {
                uart_printf("%u%u%u", (uint32_t)((vlong/10)/1000000000), (uint32_t)((vlong/10)%1000000000), (uint32_t)(vlong%10));
              } else {
                uart_printf("%u",(uint32_t)vlong);
              }
            }
          }
          break;
#endif
#ifdef FLOAT
        case 'f':
          vfloat = (float)va_arg(args, double);
          int sign = (vfloat < 0)? -1 : 1;
          uart_printf("%d.%d", (int)vfloat, (int)((sign*(vfloat-(int32_t)vfloat)+0.0005F)*1000.0F));
          break;
#endif
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

  uart_printf ("%s: Receiving and loading file...\n", PROGNAME);
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
  uart_printf("%s: File received (%d bytes)\n", PROGNAME, file_size);
  uart_endtext(); //free host from text mode
  uart_rxwait(); //wait for next command
  uart_starttext(); //renable host text mode for next mesg 
  return file_size;
}

void uart_sendfile(unsigned int file_size, char *mem) {

  uart_printf("%s: Sending file (%d bytes)\n", PROGNAME, file_size);
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
  uart_printf("%s: File sent (%d bytes)\n",  PROGNAME, file_size);
  uart_endtext(); //free host from text mode
  uart_rxwait(); //wait for next command
  uart_starttext(); //renable host text mode for next mesg 
}

void uart_connect() {
  char host_resp;

  do {
    uart_putc(ENQ);
    //    uart_sleep(1);
    host_resp = uart_getc();
  } while(host_resp != ACK);

  uart_starttext();
}




