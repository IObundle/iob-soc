#include "stdint.h"
#include "iob-uart.h"

#define PROGNAME "IOb-UART"

#define E8 100000000   //10**8
#define E16 10000000000000000  //10**16
 
void uart_puts(char *s) {
  while (*s) uart_putc(*s++);
}


void uart_printf(char* fmt, ...) {
  va_list args;
  va_start(args, fmt);

  char buffer [20];
  char *buf_ptr = 0;
  char c;
  uint32_t uv;
  int32_t v;
  uint64_t uvl;
  int64_t vl;
  int r;

  
  while ( (c = *fmt++) != '\0') {
    if (c != '%') {
      //Regular character 
      uart_putc(c);
    }
    else {
      // Format Escape Character
      if ((c = *fmt++) != '\0') {
        switch (c) {
        case '%': // %%
          uart_putc(c);
          break;
        case 'c': // %c
          uart_putc(va_arg(args, int));
          break;
        case 'x': // %x
          uv = va_arg(args, uint32_t);
          utoa(uv, buffer, 16);
          uart_puts(buffer);
          break;
        case 's': // %s
          uart_puts(va_arg(args, char *));
          break;
        case 'd':
          v = va_arg(args, int32_t);
          itoa(v, buffer, 10);
          uart_puts(buffer);
          break;
        case 'u':
          uv = va_arg(args, uint32_t);
          utoa(uv, buffer, 10);
          uart_puts(buffer);
          break;
#ifdef LONGLONG
        case 'l':
          if ((c = *fmt++) == 'l') {
            if ((c = *fmt++) == 'd') {
              vl = va_arg(args, int64_t);
              uvl = (uint64_t) vl;
              if (vl < 0) {
                uvl = (uint64_t)(-vl);
                uart_putc('-');
              }
            }
            else if (c == 'u')
              uvl = va_arg(args, uint64_t);
            else {
              uart_puts("uart_printf: ERROR: unsupported print format\n");
              exit(1);
            }

            //dec digits 20-16
            if(uvl >=  E16) {
              uart_puts(itoa((int)(uvl/E16), buffer, 10));
              //dec digits 15-8
              uvl %= E16;
              uint64_t r = E16/10;
              while(!(uvl / r)) {uart_putc('0'); r /=10;}
            }
            if(uvl >= E8) {
              uart_puts(itoa((int)(uvl/E8), buffer, 10));
              //dec digits 7-0
              uvl %= E8;
              uint64_t r = E8/10;
              while(!(uvl / r)) {uart_putc('0'); r /=10;}
            }
            if(uvl > 0)
              uart_puts(itoa((int)uvl, buffer, 10));
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
          // Unsupported format character!
          break;
        }
      }
      else {
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




