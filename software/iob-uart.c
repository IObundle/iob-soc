#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include "iob-uart.h"

#define PROGNAME "IOb-UART"

#ifdef LONGLONG
char *ulltoa(uint64_t val, uint64_t b){
  static char buf[21] = {0};
  int i = 20;
  for(; val!=0LL || i==20; i--, val /= b) {
    buf[i] = "0123456789abcdef"[(int)(val % b)];
  }
  return &buf[i+1];
}

char * lltoa(int64_t val, uint64_t b){
  int sign = (val < 0);
  val = sign? -val: val;
  char * buf = ulltoa(val, b);
  if(sign) {
        buf[-1] = '-';
        return &buf[-1];
  } else
    return buf;
}
#endif

#ifdef FLOAT
float p10[77] = {
    1E-38,
    1E-37,
    1E-36,
    1E-35,
    1E-34,
    1E-33,
    1E-32,
    1E-31,
    1E-30,
    1E-29,
    1E-28,
    1E-27,
    1E-26,
    1E-25,
    1E-24,
    1E-23,
    1E-22,
    1E-21,
    1E-20,
    1E-19,
    1E-18,
    1E-17,
    1E-16,
    1E-15,
    1E-14,
    1E-13,
    1E-12,
    1E-11,
    1E-10,
    1E-9,
    1E-8,
    1E-7,
    1E-6,
    1E-5,
    1E-4,
    1E-3,
    1E-2,
    1E-1,
    1E0, //38
    1E1,
    1E2 ,
    1E3 ,
    1E4 ,
    1E5 ,
    1E6 ,
    1E7 ,
    1E8 ,
    1E9 ,
    1E10 ,
    1E11 ,
    1E12 ,
    1E13 ,
    1E14 ,
    1E15 ,
    1E16 ,
    1E17 ,
    1E18 ,
    1E19 ,
    1E20 ,
    1E21 ,
    1E22 ,
    1E23 ,
    1E24 ,
    1E25 ,
    1E26 ,
    1E27 ,
    1E28 ,
    1E29 ,
    1E30 ,
    1E31 ,
    1E32 ,
    1E33 ,
    1E34 ,
    1E35 ,
    1E36 ,
    1E37 ,
    1E38
  };

char buf[80] = {0};

char * ftoa(float f)
{
 

  char *ptr = buf;

  //uart_printf("Got here\n");

  if(f < 0) {
    f = -f;
    *ptr++ = '-';
  }

  //uart_printf("%x\n\n", *((int *)&f));

  for(int i=38, pz=39; i>-39; i--) {

    //uart_printf("%d\n", i);

    if (f < p10[38+i]) {
      if(i<=0 || pz !=39) {
        *ptr++ = '0';
        //uart_printf("pz=%d", pz);
      }
      if(i==0) *ptr++ = '.';
      continue;
    }

    
    float test = f/(p10[38+i]);

    if(test >= 9) {
      *ptr++ = '9';
      f = f - 9*p10[38+i];
      pz = 9;
    }
    else if(test >= 8) {
      *ptr++ = '8';
      f = f - 8*p10[38+i];
      pz = 8;
    }
    else if(test >= 7) {
      *ptr++ = '7';
      f = f - 7*p10[38+i];
      pz = 7;
    }
    else if(test >= 6) {
      *ptr++ = '6';
      f = f - 6*p10[38+i];
      pz = 6;
    }
    else if(test >= 5) {
      *ptr++ = '5';
      f = f - 5*p10[38+i];
      pz = 5;
    }
    else if(test >= 4) {
      *ptr++ = '4';
      f = f - 4*p10[38+i];
      pz = 4;
    }
    else if(test >= 3) {
      *ptr++ = '3';
      f = f - 3*p10[38+i];
      pz = 3;
    }
    else if(test >= 2) {
      *ptr++ = '2';
      f = f - 2*p10[38+i];
      pz = 2;
    }
    else {
      *ptr++ = '1';
      f = f - 1*p10[38+i];
      pz = 1;
    }
    if(i==0) *ptr++ = '.';

    // uart_printf("%d\n", i);
  }

  return buf;
}
#endif

void uart_puts(char *s) {
  while (*s) uart_putc(*s++);
}

char buffer[32] = {0};

void uart_printf(char* fmt, ...) {
  va_list args;
  va_start(args, fmt);

  char c;
  uint32_t uv;
  int32_t v;
  uint64_t uvl;
  int64_t vl;
  int r;
  
  float vfloat;

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
              uart_puts(lltoa(vl, 10));
            }
            else if (c == 'u') {
              uvl = va_arg(args, uint64_t);
              uart_puts(ulltoa(uvl, 10));
            } else {
              uart_puts("printf error: unknown %ll format\n");
              exit(1);
            }
          }
          break;
#endif
#ifdef FLOAT
        case 'f':
          vfloat = (float) va_arg(args, double);
          uart_puts(ftoa(vfloat));
          break;
#endif
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




