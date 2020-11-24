//#include "stdlib.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include <stdint.h>

int main()
{
  uart_init(UART_BASE,FREQ/BAUD);
  /*
  //test hex
  uart_puts("\ntest hex\n");
  uart_printf("%x\n", 0);
  uart_printf("%x\n", 245);
  uart_printf("%x\n", (uint32_t)(~0));

  //test unsigned 
  uart_puts("\ntest unsigned\n");
  uart_printf("%u\n", 0);
  uart_printf("%u\n", 245);
  uart_printf("%u\n", (uint32_t)(~0));


  //test signed
  uart_puts("\ntest signed\n");
  uart_printf("%d\n", 0);
  uart_printf("%d\n", 245);
  uart_printf("%d\n", (int32_t)(~0));
  uart_printf("%d\n", (int32_t)(1<<31));
  uart_printf("%d\n", (int32_t)(~(1<<31)));
 
  
  //test unsigned long long
  uart_puts("\ntest unsigned long long\n");

  uart_printf("%llu\n\n", 0LL);
  uart_printf("%llu\n\n", (uint64_t)1<<29);
  uart_printf("%llu\n\n", (uint64_t)1<<30);
  uart_printf("%llu\n\n", (uint64_t)1<<31);
  uart_printf("%llu\n\n", (uint64_t)1<<32);
  uart_printf("%llu\n\n", (uint64_t)1<<33); 

  //test left shift
  int i;
  uint64_t num = 1LL;

  for (i = 0; i < 64; i++) {
    uart_printf("1 << %d = %llu\n", i, num);
    num <<= 1;
  }

  uart_printf("2**64-1 = %llu\n", ~0LL);

 
  //test signed long long
  uart_puts("test signed long long\n\n");
  uart_printf("%lld\n\n", 0LL);
  uart_printf("%lld\n\n", 1LL<<29);
  uart_printf("%lld\n\n", 1LL<<30);  
  uart_printf("%lld\n\n", 1LL<<31);
  uart_printf("%lld\n\n", 1LL<<32);
  uart_printf("%lld\n\n", 1LL<<33);

  uart_printf("%lld\n\n", ~0LL);
  uart_printf("%lld\n\n", -(1LL<<29));
  uart_printf("%lld\n\n", -(1LL<<30));  
  uart_printf("%lld\n\n", -(1LL<<31));
  uart_printf("%lld\n\n", -(1LL<<32));
  uart_printf("%lld\n\n", -(1LL<<33));
  */
  //test floats
  int x = 0b00000000100000000000000000000000; //smallest normal
  int y = 0b01111111011111111111111111111111; //largest normal

  uart_printf("%f\n", *((float *)&x));
  uart_printf("%f\n", *((float *)&y));
  uart_printf("%f\n", 0);
  uart_printf("%f\n", 1.0);
  uart_printf("%f\n", -1000000.0);
  uart_printf("%f\n", 0.000000000001);
  uart_printf("%f\n", 10000000000.0);

}
