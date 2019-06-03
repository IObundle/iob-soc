#include <stdint.h>
#include <stdbool.h>
#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define CEILING(x,y) (((x) + (y) - 1) / (y))
//#define N 10 // number of memory writes/reads
#define Address_write 0x9004 //address where the writting starts
volatile int * vect;

volatile int   flag;


#define reg_uart_clkdiv (*(volatile uint32_t*)0x70000004)
#define reg_uart_data (*(volatile uint32_t*)  0x70000008)


// ---------------------------------------------------------------

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

// -----------------------------------------------------------------



//--------------------
//led
//--------------------
/*
void led_set(unsigned char led)
{
  *((volatile int*) 0x10000010) = led;
}

//--------------------
//uart
//--------------------

#define uart_reset() (*((volatile int*) 0x7000000C) = 1)

void uart_setdiv(int div)
{
  *((volatile int*) 0x70000004) = div;
}

int uart_getwait()
{
  return *((volatile int*) 0x70000000);
}

void uart_wait()
{
  // led_set(1);
  while(uart_getwait());
  //led_set(0);
}

int uart_getdiv()
{
  return *((volatile int*) 0x70000004);
}
 
void uart_putc(char c)
{
  // led_set(1);
  while( *( (volatile int *) 0x70000000) );
  //led_set(0);

  *( (volatile int *) 0x70000008 ) = (int) c;
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
      // Regular character 
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
          // Process hexadecimal number format. 
	// If the number value is zero, just print and continue. 
          if (var == 0)
            {
              uart_putc('0');
              continue;
            }

          // Find first non-zero digit. 
          digit_shift = 28;
          while (!(var & (0xF << digit_shift))) {
            digit_shift -= 4;
          }

          // Print digits. 
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

          // Reset the A character 
          hex_a = 'a';
          break;
        default:
          // Unsupported format character!
          break;
      }
    }
  }
}
*/
/*
//--------------------
//spi 
//--------------------

#define SPI_MASTER_TOP_0_BASE 0x10000100
#define SPI_SLAVE_TOP_0_BASE 0x10000200

#define SPI_READY 1
#define SPI_TXDATA 2
#define SPI_RXDATA 3
#define SPI_VERSION 5
#define SPI_SOFTRESET 6
#define SPI_DUMMY 7

#define RAM_SET32(base, location, value) *((volatile int*) (base + (sizeof(int)) * location)) = value
#define RAM_GET32(base, location)        *((volatile int*) (base + (sizeof(int)) * location))

void spiMasterInit(void)
{
  if (RAM_GET32(SPI_MASTER_TOP_0_BASE, SPI_READY) == 0)
    uart_puts("spi master not ready.\n");

  // check processor interface
  // write dummy register
  RAM_SET32(SPI_MASTER_TOP_0_BASE, SPI_DUMMY, 0xDEADBEEF);

  // read and check result 
  if (RAM_GET32(SPI_MASTER_TOP_0_BASE, SPI_DUMMY) != 0xDEADBEEF)
    uart_puts("spi master dummy reg test failed\n");
}

void spiMasterWrite(int w)
{
  // set tx register
  RAM_SET32(SPI_MASTER_TOP_0_BASE, SPI_TXDATA, w);
  // wait until all bits are transmitted
  while (RAM_GET32(SPI_MASTER_TOP_0_BASE, SPI_READY) == 0) ;
}

int spiMasterRead()
{
  // reset the tx register to init a read spi cycle
  RAM_SET32(SPI_MASTER_TOP_0_BASE, SPI_TXDATA, 0);
  // wait until cycle complete
  while (RAM_GET32(SPI_MASTER_TOP_0_BASE, SPI_READY) == 0) ;
}

void spiSlaveWrite(int w)
{
  // set tx register
  RAM_SET32(SPI_SLAVE_TOP_0_BASE, SPI_TXDATA, w);
}


int spiSlaveRead(void)
{
  int srw;

  // wait until ready to read 
  while (RAM_GET32(SPI_SLAVE_TOP_0_BASE, SPI_READY) == 0) ;

  // read received word 
  srw = RAM_GET32(SPI_SLAVE_TOP_0_BASE, SPI_RXDATA);

  return srw;
}


//lib
void *memcpy(void *dest, const void *src, int n)
{
  while (n) {
    n--;
    ((char*)dest)[n] = ((char*)src)[n];
  }
  return dest;
}

*/





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
 
 print("... Initializing program in main memory:\n");
  //uart_puts("D\n");
 // uart_puts("... Initializing program in main memory:\n");
 // uart_wait();

 vect = (volatile int*) Address_write;

 print("Writting number at 0x");
 print_hex(Address_write, 8);
  //uart_puts("W\n");
 // uart_printf("Starting number writting at 0x%x\n", Address_write);
 // uart_wait(); 

 while(1){
   print("\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n");
   /* Numb = getchar();
   while ( Numb > '9' || Numb < '0'){
     print("Incorrect value, type 0 to f\n");
     Numb = getchar();

   };
   N1 = (int) Numb-48;
   /*print ("\nN0 = ");

   N =(int) ((N1)<<4 + N0);

   for (counter = 0; counter <= N; counter ++){
    vect[counter] = counter;
  };
   */
   // N = (int) Numb - 48;
   print ("N3 = ");
   Numb = getchar();
   /*   while (Numb > '9' || Numb < '0'){
	   while (Numb > 'f' || Numb < 'a'){
	     print("Incorrect value, type 0 to f\n");
	     Numb = getchar();
	   }
       print("Incorrect value, type 0 to f\n");
       Numb = getchar(); 
       } */
   if (Numb <= '9'){
     N3 =(int) Numb - 48;
   }else{
     N3 =(int) Numb - 87;
   }
   print_hex (N3, 4);
   N3 = N3<<12;


   print ("\nN2 = ");
   Numb = getchar();
   /* while (Numb > '9' || Numb < '0'){
	   while (Numb > 'f' || Numb < 'a'){
	     print("Incorrect value, type 0 to f\n");
	     Numb = getchar();
	   }
       print("Incorrect value, type 0 to f\n");
       Numb = getchar(); 
       } */
   if (Numb <= '9'){
     N2 =(int) Numb - 48;
   }else{
     N2 =(int) Numb - 87;
   }
   print_hex (N2, 4);
   N2 = N2<<8;


   print ("\nN1 = ");
   Numb = getchar();
   /* while (Numb > '9' || Numb < '0'){
	   while (Numb > 'f' || Numb < 'a'){
	     print("Incorrect value, type 0 to f\n");
	     Numb = getchar();
	   }
       print("Incorrect value, type 0 to f\n");
       Numb = getchar(); 
       } */
   if (Numb <= '9'){
     N1 =(int) Numb - 48;
   }else{
     N1 =(int) Numb - 87;
   }
   print_hex (N1, 4);
   N1 = N1<<4;

   print ("\nN0 = ");
   /*   Numb = getchar();
   while (Numb > '9' || Numb < '0'){
	   while (Numb > 'f' || Numb < 'a'){
	     print("Incorrect value, type 0 to f\n");
	     Numb = getchar();
	   }
       print("Incorrect value, type 0 to f\n");
       Numb = getchar(); 
   } 
   */   if (Numb <= '9'){
     N0 =(int) Numb - 48;
   }else{
     N0 =(int) Numb - 87;
   }
   print_hex (N0, 4);

   N = N3 + N2 + N1 + N0;
   print("\nN =");
   print_hex (N, 4);


   for (counter = 0; counter <= N; counter ++){
    vect[counter] = counter;
  };


   print ("\nWrite verification:\n");
  //uart_puts("V\n");
//  uart_puts("Write verification:\n");
//  uart_wait();

  //flag =  105;
  //reg = vect[0]; //initialization-read
 
  for (counter = 0; counter <= N; counter ++){
    if(vect[counter] != counter)
      {
	print_hex(vect[counter],5);
	print(" should've been ");
	print_hex(counter, 5);
	print("\n");
	//flag = 26985;
	//uart_printf("%x should've been ",vect[counter]); 
	//uart_wait();
	//	uart_printf("%x\n",counter); 
	//	uart_wait();
      };
  };

print ("Write print:\n");
  //uart_puts("P\n");
 // uart_puts("Write print:\n");
 // uart_wait(); 

  for (counter = 0; counter <= N; counter ++)
    {
      print(" ");
      print_hex (vect[counter], 5);
      //  uart_printf("%x _ ",vect[counter]); 
      //uart_wait(); 
    };
  
  print("\nEnd of program.\n");
  //uart_puts("\nEnd of program.\n");
  //uart_wait(); 
}  
  //while (1);
}
