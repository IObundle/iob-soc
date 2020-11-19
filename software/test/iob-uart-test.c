//#include "stdlib.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include <stdint.h>
int main()
{
  //init uart

  uart_init(UART_BASE,FREQ/BAUD);

  uart_printf("%u\n", 0);
  uart_printf("%u\n", 245);
  uart_printf("%u\n", (uint32_t)(~0));
  uart_printf("%d\n", 245);
  uart_printf("%d\n", (int32_t)(~0));

  
  //test unsigned
  uint64_t l = (uint64_t)1<<29;
  uart_printf("%llu\n\n", l);
  
  uint64_t m = (uint64_t)1<<30;
  uart_printf("%llu\n\n", m);
  
  uint64_t n = (uint64_t)1<<31;
  uart_printf("%llu\n\n", n);
  
  uint64_t o = (uint64_t)1<<32;
  uart_printf("%llu\n\n", o);
  
  uint64_t p = (uint64_t)1<<33;
  uart_printf("%llu\n\n", p);


  
   //test signed
  int64_t a = (int64_t)1<<29;
  uart_printf("%lld\n\n", a);
 
  int64_t b = (int64_t)1<<30;
  uart_printf("%lld\n\n", b);
  
  int64_t c = (int64_t)1<<31;
  uart_printf("%lld\n\n", c);
  
  int64_t d = (int64_t)1<<32;
  uart_printf("%lld\n\n", d);
  
  int64_t e = (int64_t)1<<33;
  uart_printf("%lld\n\n", e);
  
  int64_t f = -((int64_t)1<<29);
  uart_printf("%lld\n\n", f);

  int64_t g = -((int64_t)1<<30);
  uart_printf("%lld\n\n", g);
  
  int64_t h = -((int64_t)1<<31);
  uart_printf("%lld\n\n", h);

  int64_t i = -((int64_t)1<<32);
  uart_printf("%lld\n\n", i);
  
  int64_t j = -((int64_t)1<<33);
  uart_printf("%lld\n\n", j);

  
  int32_t q;
  uint64_t num = 1;

  
  for (q = 0; q < 64; q++) {
    //uart_printf("num[%d] = %x%x\n", q, (num>>32), num);
    uart_printf("num[%d] = %llu\n", q, num);
    num = num<<1;
  }
  
  num = 1;
  for (q = 0; q < 20; q++) {
    //uart_printf("num[%d] = %x%x\n", q, (num>>32), num);
    uart_printf("num[%d] = %llu\n", q, num);
    num = num * (uint64_t)10;
  }

  num = ~(uint64_t)0;
  uart_printf("num[%d] = %llu\n", q, num);

  uart_printf("num[%d] = %lls\n", q, num);


}
