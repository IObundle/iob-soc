#include <stdint.h>
#include <stdbool.h>
#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFC 
//#define PROG_SIZE 4096
#define PROG_SIZE 5

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
  int counter, i, a;
  char* uart_char;
  int*  int_uart;     

  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;


  //uart_reset();
  reg_uart_clkdiv = 868;
  //uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  //uart_wait();  
 
  //uart_puts("C\n");
  // uart_puts("Copying Program to Main Memory...\n");
  //uart_wait(); 

  //print ("Copying Program from UART to Main Memory, load it from terminal...");

  /*
  for (counter = 0; counter < PROG_SIZE; counter++){
    print ("\nposition ");
    print_hex (counter, 3);
    print(":\n");
    for (incr = 0; incr < 8; incr++){
      uart_char [incr] = getchar();
    }
    for (incr =0; incr < 8; incr++){
      if (uart_char[incr] <= '9' || uart_char [incr] >= '0'){
	a = (int) uart_char [incr] - 48; //0 - 9
      }else{ 
	a = (int) uart_char [incr] - 87; //a - f
      }
      print (" "); 
      print_hex (a, 1);
      print (" -> ");
      int_uart[incr] = a<<(4*incr);
      print_hex (int_uart[incr], 8);
      print("\n");
    }
    MAIN_MEM[counter] = 0;
    for (incr =0; incr <8 ; incr++){
      MAIN_MEM[counter] = MAIN_MEM[counter] + int_uart [incr];
    }
    print ("- written value: ");
    print_hex (MAIN_MEM[counter],8);
    print("\n");
  }
   
  //uart_puts("S\n");
  //uart_puts("Program copy completed. Starting to read from Main Memory...\n");
  //uart_wait(); 
  print("Program copy completed. Starting to read from Main Memory...\n");


  *((volatile int*) MEM_JUMP) = 1;
}
*/


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
  while (1){
    print ("\nTesting UART loading to Main Memory...");

    for (i = 0 ; i < PROG_SIZE; i ++){

      for (counter = 7; counter >= 0 ; counter--) {
	MAIN_MEM[(8*i) + counter] = getchar();
	print("\nValue sent: ");
	print_hex(MAIN_MEM[(8*i) + counter], 3);
	if (MAIN_MEM [(8*i) + counter] >='0'  && MAIN_MEM [(8*i) + counter] <= '9'){
	  MAIN_MEM [(8*i) + counter] = MAIN_MEM[(8*i) + counter] - 48;
	}else{
	  MAIN_MEM [(8*i) + counter] = MAIN_MEM [(8*i) + counter] - 87;
	}
	print(" - char of: ");
	print_hex(MAIN_MEM[(8*i) + counter], 3);
      }
  

      for (counter = 0; counter < 8; counter ++){
	MAIN_MEM[(8*i) + counter] <<= (4*counter);
	print("\nShifted value: ");
	print_hex(MAIN_MEM[(8*i) + counter], 8);    
      }

      MAIN_MEM[i] = MAIN_MEM [8*i]; //puts the instruction in order (from address 8*i to i)
      for (counter = 1; counter < 8; counter ++){
	MAIN_MEM[i] = MAIN_MEM[i] + MAIN_MEM[(8*i) + counter];
      }
      print("\nFinal value: ");
      print_hex(MAIN_MEM[i], 8);

    }

      print("\nProgram copy completed... Printing final copy:\n");
      for (i = 0 ; i < PROG_SIZE; i++){
	print_hex (i, 3);
	print (": ");
	print_hex (MAIN_MEM[i], 8);
	print("\n");
      }
  }
  //  *((volatile int*) MEM_JUMP) = 1;
}


