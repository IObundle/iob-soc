#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE 115200 // can also use 115200
#define CEILING(x,y) (((x) + (y) - 1) / (y))
#define N 10 // number of memory writes/reads
#define Address_write 0x9000 //address where the writting starts
volatile int * vect;

volatile int   flag;

//--------------------
//led
//--------------------

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
      /* Regular character */
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
          /* Process hexadecimal number format. */
          /* If the number value is zero, just print and continue. */
          if (var == 0)
            {
              uart_putc('0');
              continue;
            }

          /* Find first non-zero digit. */
          digit_shift = 28;
          while (!(var & (0xF << digit_shift))) {
            digit_shift -= 4;
          }

          /* Print digits. */
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

          /* Reset the A character */
          hex_a = 'a';
          break;
        default:
          /* Unsupported format character! */
          break;
      }
    }
  }
}


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







//--------------------
//main program
//--------------------

void main()
{ 
  int counter, reg = 0 ;
  unsigned char ledvar = 0;

 

  uart_reset();
  //  *((volatile int*) 0x1000000C) = 1;

  
  uart_setdiv(UART_CLK_FREQ/UART_BAUD_RATE);
  uart_wait();  
 
   uart_puts("D1\n");
  //uart_puts("... Initializing program in main memory:\n");
  uart_wait();  
  
  uart_puts("D2\n");
  //uart_puts("... Initializing program in main memory:\n");
  uart_wait();

  vect = (volatile int*) Address_write;

  uart_puts("W\n");
  //uart_printf("Starting number writting at 0x%x\n",Address_write);
  uart_wait(); 


  for (counter = 0; counter <= N; counter ++){
    vect[counter] = counter;
  };

  uart_puts("V\n");
  //uart_puts("Write verification:\n");
  uart_wait();

  //flag =  105;
  //reg = vect[0]; //initialization-read
  
  for (counter = 0; counter <= N; counter ++){
    if(vect[counter] != counter)
      {
	//flag = 26985;
		uart_printf("%x should've been ",vect[counter]); 
		uart_wait();
		uart_printf("%x\n",counter); 
		uart_wait();
      };
  };

  uart_puts("P\n");
  //uart_puts("Write print:\n");
  uart_wait(); 

  for (counter = 0; counter <= N; counter ++)
    {
      uart_printf("%x _ ",vect[counter]); 
      uart_wait(); 
    };

  uart_puts("\nEnd of program.\n");
  uart_wait(); 

  while (1);
}
