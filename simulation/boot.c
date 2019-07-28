#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define UART_CLK_FREQ 200000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define UART_ADDRESS 0x70000000
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFC 
#define PROG_SIZE 2048 


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



volatile int* MAIN_MEM;
volatile int* PROG_MEM;
volatile int* PC_SOFT_RESET;

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


// -----------------------------------------------------------------

void main()
{ 
  int counter, i = 0;
  int a;
  char* uart_char;
  int*  int_uart;     

  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;




  uart_init(UART_ADDRESS,868);

  //uart_write_wait();
  // reg_uart_clkdiv = 868;
  //reg_uart_clkdiv = 2170;
  /*

    for (counter = 0; counter < PROG_SIZE; counter ++){
    MAIN_MEM[counter] = PROG_MEM[counter];
    };

    //uart_puts("S\n");
    //uart_puts("Program copy completed. Starting to read from Main Memory...\n");
    //uart_wait(); 
    print("Program copy completed. Starting to read from Main Memory...\n");


    *((volatile int*) MEM_JUMP) = 1;
    }
  */
  uart_write_wait();
  uart_puts ("\nLoad Program throught UART to Main Memory...\n");

  for (i = 0 ; i < PROG_SIZE; i ++){

    for (counter = 7; counter >= 0 ; counter--) {

      //	MAIN_MEM[(8*i) + counter] = getchar();
      //uart_read_wait();
      uart_read_wait();
      MAIN_MEM[(8*i) + counter] = uart_getc();
      //	print("\nValue sent: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      if (MAIN_MEM [(8*i) + counter] >='0'  && MAIN_MEM [(8*i) + counter] <= '9'){
	MAIN_MEM [(8*i) + counter] = MAIN_MEM[(8*i) + counter] - 48;
      }else{
	MAIN_MEM [(8*i) + counter] = MAIN_MEM [(8*i) + counter] - 87;
      }
      //	print(" - char of: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      //	uart_printf("%x", MAIN_MEM[(8*i) + counter]);
    }
    // uart_puts("\n");
      
    for (counter = 0; counter < 8; counter ++){
      //	print("\n");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      MAIN_MEM[(8*i) + counter] = MAIN_MEM[(8*i) + counter] << (4*counter);
      //	print(" - shifted value: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 8);    
    }

    MAIN_MEM[i] = MAIN_MEM [8*i]; //puts the instruction in order (from address 8*i to i)
    for (counter = 1; counter < 8; counter ++){
      MAIN_MEM[i] = MAIN_MEM[i] + MAIN_MEM[(8*i) + counter];
    }
    // print("\nFinal value: ");
    //print_hex(MAIN_MEM[i], 8);
    //print("Line: ");
    // print_hex(i, 3);
    //print("\n");
  }
  uart_write_wait();
  uart_puts("\nProgram copy completed... Printing final copy:\n");
  for (i = 0 ; i < PROG_SIZE; i++){
    // print_hex (i, 3);
    // print (": ");
    // print_hex (MAIN_MEM[i], 8);
    // print("\n");
    uart_write_wait();
    uart_printf("%x: ", 4*i);
    uart_write_wait();
    uart_printf("%x\n", MAIN_MEM[i]);
  }
  uart_write_wait();
  uart_puts("\nPreparing to start the Main Memory program...\n");    

  *((volatile int*) MEM_JUMP) = 1;
  //counter = PC_SOFT_RESET[0];
}





