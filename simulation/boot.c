#include <stdint.h>
#include <stdbool.h>
#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFC 
#define PROG_SIZE 1024

#define reg_uart_clkdiv (*(volatile uint32_t*)0x70000004)
#define reg_uart_data (*(volatile uint32_t*)  0x70000008)

volatile int* MAIN_MEM;
volatile int* PROG_MEM;
//--------------------
//main booting program
//--------------------
/*
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
  while(uart_getwait());
}

void uart_putc(char c)
{
  while( *( (volatile int *) 0x70000000) );
  *( (volatile int *) 0x70000008 ) = (int) c;
}

void uart_puts(const char *s)
{
  while (*s) uart_putc(*s++);
}
*/


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

void main()
{ 
  int counter;
        

  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;


  //uart_reset();
  reg_uart_clkdiv = 868;
  //uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  //uart_wait();  
 
  //uart_puts("C\n");
  // uart_puts("Copying Program to Main Memory...\n");
  //uart_wait(); 
  print ("Copying Program to Main Memory...\n");


  for (counter = 0; counter < PROG_SIZE; counter ++){
    MAIN_MEM[counter] = PROG_MEM[counter];
  };

  //uart_puts("S\n");
  //uart_puts("Program copy completed. Starting to read from Main Memory...\n");
  //uart_wait(); 
  print("Program copy completed. Starting to read from Main Memory...\n");


  *((volatile int*) MEM_JUMP) = 1;
}
