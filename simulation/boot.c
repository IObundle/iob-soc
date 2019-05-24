#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define MAIN_MEM_ADDR 0x80000000
#define PROG_MEM_ADDR 0x40000000
//#define MEM_JUMP 0xBFFFFFFC 
#define MEM_JUMP 0xFFFFFFFF 
#define PROG_SIZE 1024
volatile int* MAIN_MEM;
volatile int* PROG_MEM;
//--------------------
//main booting program
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

void main()
{ 
  int counter;
        

  MAIN_MEM = (volatile int*) MAIN_MEM_ADDR;
  PROG_MEM = (volatile int*) PROG_MEM_ADDR;


  uart_reset();
  uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  uart_wait();  
 
  uart_puts("C\n");
  //uart_puts("Copying Program to Main Memory...\n");
  uart_wait(); 


  for (counter = 0; counter < PROG_SIZE; counter ++){
    MAIN_MEM[counter] = PROG_MEM[counter];
  };

  uart_puts("S\n");
  //uart_puts("Program copy completed. Starting to read from Main Memory...\n");
  uart_wait(); 

  *((volatile int*) MEM_JUMP) = 1;
}
