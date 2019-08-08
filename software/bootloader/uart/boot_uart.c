#include <stdint.h>
#include <stdbool.h>
#define UART_CLK_FREQ 200000000 // 100 MHz
#define UART_BAUD_RATE   115200 // can also use 115200
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFC 
//#define PROG_SIZE 4096
#define PROG_SIZE 2048

#define reg_uart_clkdiv (*(volatile uint32_t*)0x70000004)
#define reg_uart_data (*(volatile uint32_t*)  0x70000008)

//volatile int* MAIN_MEM;
volatile int* MAIN_MEM;
volatile int* PROG_MEM;
volatile int* PC_SOFT_RESET;
//--------------------
//main booting program
//--------------------

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
  int counter, i = 0;
  int a;
  char* uart_char;
  int*  int_uart;     

  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;
  PC_SOFT_RESET  = (volatile int*) MEM_JUMP;

  //reg_uart_clkdiv = (int)(UART_CLK_FREQ/UART_BAUD_RATE);
  //reg_uart_clkdiv = 868;
  reg_uart_clkdiv = 5;

  print ("\nLoad Program throught UART to Main Memory...\n");
  putchar(0x11);

  for (i = 0 ; i < PROG_SIZE; i ++){

    for (counter = 7; counter >= 0 ; counter--) {

      MAIN_MEM[(8*i) + counter] = getchar();
      //	print("\nValue sent: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
      if (MAIN_MEM [(8*i) + counter] >='0'  && MAIN_MEM [(8*i) + counter] <= '9'){
	MAIN_MEM [(8*i) + counter] = MAIN_MEM[(8*i) + counter] - 48;
      }else{
	MAIN_MEM [(8*i) + counter] = MAIN_MEM [(8*i) + counter] - 87;
      }
      //	print(" - char of: ");
      //	print_hex(MAIN_MEM[(8*i) + counter], 3);
    }
      
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
      
  /* print("\nProgram copy completed... Printing final copy:\n");
  for (i = 0 ; i < PROG_SIZE; i++){
    print_hex (4*i, 3);
    print (": ");
    print_hex (MAIN_MEM[i], 8);
    print("\n");
  }
  */
  
  print("\nProgram copy completed...\n");
  print("\nPreparing to start the Main Memory program...\n");    

   *((volatile int*) MEM_JUMP) = 1;
  //counter = PC_SOFT_RESET[0];
}





