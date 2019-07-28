#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define UART_ADDRESS 0x70000000
#define Address_write 0x9004 //address where the writting starts
#define N 1000
volatile int * vect;



//#define reg_uart_clkdiv (*(volatile uint32_t*)0x70000004)
//#define reg_uart_data (*(volatile uint32_t*)  0x70000008)


#define MEMSET(base, location, value) (*((volatile int*) (base + (sizeof(int)) * location)) = value)
#define MEMGET(base, location)        (*((volatile int*) (base + (sizeof(int)) * location)))

//Memory Map
#define UART_WRITE_WAIT 0
#define UART_DIV        1
#define UART_DATA       2
#define UART_SOFT_RESET 3
#define UART_READ_VALID 4


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
	  //sprintf(buffer, "%x", v);
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


// ---------------------------------------------------------------
/*
  void putchar(char c)
  {
  if (c == '\n')
  putchar('\r');
  reg_uart_data = c;
  }

  void print(const char *p)
  {
  while (*p)
  putchar(*(p++));
  }

  void print_hex(uint32_t v, int digits)
  {
  for (int i = 7; i >= 0; i--) {
  char c = "0123456789abcdef"[(v >> (4*i)) & 15];
  if (c == '0' && i >= digits) continue;
  putchar(c);
  digits = i;
  }
  }

  void print_dec(uint32_t v)
  {
  if (v >= 1000) {
  print(">=1000");
  return;
  }

  if      (v >= 900) { putchar('9'); v -= 900; }
  else if (v >= 800) { putchar('8'); v -= 800; }
  else if (v >= 700) { putchar('7'); v -= 700; }
  else if (v >= 600) { putchar('6'); v -= 600; }
  else if (v >= 500) { putchar('5'); v -= 500; }
  else if (v >= 400) { putchar('4'); v -= 400; }
  else if (v >= 300) { putchar('3'); v -= 300; }
  else if (v >= 200) { putchar('2'); v -= 200; }
  else if (v >= 100) { putchar('1'); v -= 100; }

  if      (v >= 90) { putchar('9'); v -= 90; }
  else if (v >= 80) { putchar('8'); v -= 80; }
  else if (v >= 70) { putchar('7'); v -= 70; }
  else if (v >= 60) { putchar('6'); v -= 60; }
  else if (v >= 50) { putchar('5'); v -= 50; }
  else if (v >= 40) { putchar('4'); v -= 40; }
  else if (v >= 30) { putchar('3'); v -= 30; }
  else if (v >= 20) { putchar('2'); v -= 20; }
  else if (v >= 10) { putchar('1'); v -= 10; }

  if      (v >= 9) { putchar('9'); v -= 9; }
  else if (v >= 8) { putchar('8'); v -= 8; }
  else if (v >= 7) { putchar('7'); v -= 7; }
  else if (v >= 6) { putchar('6'); v -= 6; }
  else if (v >= 5) { putchar('5'); v -= 5; }
  else if (v >= 4) { putchar('4'); v -= 4; }
  else if (v >= 3) { putchar('3'); v -= 3; }
  else if (v >= 2) { putchar('2'); v -= 2; }
  else if (v >= 1) { putchar('1'); v -= 1; }
  else putchar('0');
  }

  char getchar_prompt(char *prompt)
  {
  int32_t c = -1;

  uint32_t cycles_begin, cycles_now, cycles;
  __asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

  //reg_leds = ~0;

  if (prompt)
  print(prompt);

  while (c == -1) {
  __asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
  cycles = cycles_now - cycles_begin;
  if (cycles > 12000000) {
  if (prompt)
  print(prompt);
  cycles_begin = cycles_now;
  //	reg_leds = ~reg_leds;
  }
  c = reg_uart_data;
  }

  //	reg_leds = 0;
  return c;
  }

  char getchar()
  {
  return getchar_prompt(0);
  }
*/
// -----------------------------------------------------------------

//--------------------
//main program
//--------------------

void main()
{ 
  int counter, reg = 0 ;
  unsigned char ledvar = 0;
  unsigned char Numb = 0;

  uart_init(UART_ADDRESS,(UART_CLK_FREQ/UART_BAUD_RATE));
   
  uart_write_wait();
  uart_puts("... Initializing program in main memory:\n");
  vect = (volatile int*) Address_write;

  for (counter = 0; counter < N; counter ++){
    vect[counter] = counter;
  }
  uart_write_wait();
  uart_puts("Wrote all numbers, the last printed: \n");
  uart_write_wait();
  uart_printf("%x\n", vect[N-1]);
  uart_write_wait();
  uart_puts("Verification of said numbers:\n");

  for (counter = 0; counter < N; counter ++){
    if (vect[counter] != counter){
      //    print("failed at: ");
      //print_hex (vect[counter], 5);
      //print("\n");
      uart_write_wait();
      uart_printf("fail:%x\n", counter);
    }
  }
  uart_write_wait();
  uart_puts("End of program\n");

  while(1);

}
