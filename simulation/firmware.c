#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define CEILING(x,y) (((x) + (y) - 1) / (y))
//#define N 10 // number of memory writes/reads
#define Address_write 0x9004 //address where the writting starts


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


volatile int * vect;

volatile int   flag;




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



//--------------------
//main program
//--------------------

void main()
{ 
  int counter, reg = 0 ;
  unsigned char ledvar = 0;
  unsigned char Numb = 0;
  int N3, N2, N1, N0, N =0;

  //uart_reset();
  //  *((volatile int*) 0x1000000C) = 1;

  
  //uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  //uart_wait();  
 
  //print("... Initializing program in main memory:\n");
  //uart_puts("D\n");
 uart_puts("... Initializing program in main memory:\n");
 // uart_wait();
 
 vect = (volatile int*) Address_write;

 //print("Writting number at 0x");
 //print_hex(Address_write, 8);
  //uart_puts("W\n");
  uart_printf("Starting number writting at 0x%x\n", Address_write);
 // uart_wait(); 
 
 while(1){
   // print("\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n");
   uart_puts("\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n");
   
   // N = (int) Numb - 48;
   uart_puts ("N3 = ");
   Numb = uart_getc();
   if (Numb <= '9'){
     N3 =(int) Numb - 48;
   }else{
     N3 =(int) Numb - 87;
   }
   
   
// print_hex (N3, 4);
   uart_printf("%x", N3);
   N3 = N3<<12;
   

  uart_puts("\nN2 = ");
   Numb = uart_getc();
   
   if (Numb <= '9'){
     N2 =(int) Numb - 48;
   }else{
     N2 =(int) Numb - 87;
   }
   //  print_hex (N2, 4);
   uart_printf("%x", N2);
   N2 = N2<<8;
   

   uart_puts ("\nN1 = ");
   Numb = uart_getc();
   if (Numb <= '9'){
     N1 =(int) Numb - 48;
   }else{
     N1 =(int) Numb - 87;
   }
   //print_hex (N1, 4);
   uart_printf("%x", N1);
   N1 = N1<<4;
   /*
   uart_puts ("\nN0 = ");
   Numb = getchar();
   if (Numb <= '9'){
     N0 =(int) Numb - 48;
   }else{
     N0 =(int) Numb - 87;
   }
   //print_hex (N0, 4);
   uart_printf("%x", N0);
   
   N = N3 + N2 + N1 + N0;
   //   print("\nN =");
   //print_hex (N, 4);
   uart_printf("\nN = %x\n", N);

   for (counter = 0; counter <= N; counter ++){
    vect[counter] = counter;
  };


   //print ("\nWrite verification:\n");
  //uart_puts("V\n");
  uart_puts("Write verification:\n");
//  uart_wait();

  //flag =  105;
  //reg = vect[0]; //initialization-read
 
  for (counter = 0; counter <= N; counter ++){
    if(vect[counter] != counter)
      {
	//print_hex(vect[counter],5);
	//print(" should've been ");
	//print_hex(counter, 5);
	//print("\n");
	//flag = 26985;
	uart_printf("%x should've been ",vect[counter]); 
	//uart_wait();
	uart_printf("%x\n",counter); 
	//	uart_wait();
      };
  };

  //print ("Write print:\n");
  //uart_puts("P\n");
  uart_puts("Write print:\n");
 // uart_wait(); 

  for (counter = 0; counter <= N; counter ++)
    {
      //print(" ");
      //print_hex (vect[counter], 5);
      uart_printf("%x _ ",vect[counter]); 
      //uart_wait(); 
    };
  
  //print("\nEnd of program.\n");
  uart_puts("\nEnd of program.\n");
  //uart_wait(); 
*/
}  
 
 //while (1);
}
