//#include "stdlib.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include <stdint.h>

int main()
{
  uart_init(UART_BASE,FREQ/BAUD);

  uint64_t a = 0x0000001000000000LL;
  uint64_t b = 0x0000000000001100LL;

  uint64_t d = 0x0000001000001100LL;
  uint64_t c = iob_llsum(a,b);
  uint64_t e = iob_llmul(a,b);
  uint64_t f = iob_lldiv(a,b);
  uint64_t g = iob_llrem(a,b);

  uart_printf("const %x %x\n\n", *((uint32_t *)(&d)+1), *((uint32_t *)(&d)));
  uart_printf("add %x %x\n\n", *((uint32_t *)(&c)+1), *((uint32_t *)(&c)));
  uart_printf("mul %x %x\n\n", *((uint32_t *)(&e)+1), *((uint32_t *)(&e)));
  uart_printf("div %x %x\n\n", *((uint32_t *)(&f)+1), *((uint32_t *)(&f)));
  uart_printf("rem %x %x\n\n", *((uint32_t *)(&g)+1), *((uint32_t *)(&g)));

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
