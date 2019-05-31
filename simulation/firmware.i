# 1 "firmware.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "firmware.c"
# 1 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdint.h" 1 3 4
# 11 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdint.h" 3 4
# 1 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdint-gcc.h" 1 3 4
# 34 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdint-gcc.h" 3 4

# 34 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdint-gcc.h" 3 4
typedef signed char int8_t;


typedef short int int16_t;


typedef long int int32_t;


typedef long long int int64_t;


typedef unsigned char uint8_t;


typedef short unsigned int uint16_t;


typedef long unsigned int uint32_t;


typedef long long unsigned int uint64_t;




typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef long int int_least32_t;
typedef long long int int_least64_t;
typedef unsigned char uint_least8_t;
typedef short unsigned int uint_least16_t;
typedef long unsigned int uint_least32_t;
typedef long long unsigned int uint_least64_t;



typedef int int_fast8_t;
typedef int int_fast16_t;
typedef int int_fast32_t;
typedef long long int int_fast64_t;
typedef unsigned int uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;
typedef long long unsigned int uint_fast64_t;




typedef int intptr_t;


typedef unsigned int uintptr_t;




typedef long long int intmax_t;
typedef long long unsigned int uintmax_t;
# 12 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdint.h" 2 3 4
# 2 "firmware.c" 2
# 1 "/opt/riscv/lib/gcc/riscv32-unknown-elf/7.2.0/include/stdbool.h" 1 3 4
# 3 "firmware.c" 2






# 8 "firmware.c"
volatile int * vect;

volatile int flag;
# 19 "firmware.c"
void putchar(char c)
{
 if (c == '\n')
  putchar('\r');
 (*(volatile uint32_t*) 0x70000008) = c;
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

 if (v >= 900) { putchar('9'); v -= 900; }
 else if (v >= 800) { putchar('8'); v -= 800; }
 else if (v >= 700) { putchar('7'); v -= 700; }
 else if (v >= 600) { putchar('6'); v -= 600; }
 else if (v >= 500) { putchar('5'); v -= 500; }
 else if (v >= 400) { putchar('4'); v -= 400; }
 else if (v >= 300) { putchar('3'); v -= 300; }
 else if (v >= 200) { putchar('2'); v -= 200; }
 else if (v >= 100) { putchar('1'); v -= 100; }

 if (v >= 90) { putchar('9'); v -= 90; }
 else if (v >= 80) { putchar('8'); v -= 80; }
 else if (v >= 70) { putchar('7'); v -= 70; }
 else if (v >= 60) { putchar('6'); v -= 60; }
 else if (v >= 50) { putchar('5'); v -= 50; }
 else if (v >= 40) { putchar('4'); v -= 40; }
 else if (v >= 30) { putchar('3'); v -= 30; }
 else if (v >= 20) { putchar('2'); v -= 20; }
 else if (v >= 10) { putchar('1'); v -= 10; }

 if (v >= 9) { putchar('9'); v -= 9; }
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



 if (prompt)
  print(prompt);

 while (c == -1) {
  __asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
  cycles = cycles_now - cycles_begin;
  if (cycles > 12000000) {
   if (prompt)
    print(prompt);
   cycles_begin = cycles_now;

  }
  c = (*(volatile uint32_t*) 0x70000008);
 }


 return c;
}

char getchar()
{
 return getchar_prompt(0);
}
# 321 "firmware.c"
void main()
{
  int counter, reg = 0 ;
  unsigned char ledvar = 0;
  unsigned char Numb = 0;
  int N3, N2, N1, N0, N =0;
# 335 "firmware.c"
 print("... Initializing program in main memory:\n");




  vect = (volatile int*) 0x1000;

print("Writting number at 0x");
print_hex(0x1000, 8);




 while(1){
   print("\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n");
# 366 "firmware.c"
   N3 = 5;
   print ("N3 = ");
   print_hex (N3, 1);

   N3 = N3<<4;
   print ("\nN3<<4 = ");
   print_hex (N3, 8);

   N2 = 6;
   print ("\nN2 = ");
   print_hex (N2, 1);
   N1 = 7;
   print ("\nN1 = ");
   print_hex (N1, 1);
   N0 = 8;
   print ("\nN0 = ");
   print_hex (N0 , 1);
   N = (N3)<<12 + (N2)<<8 + (N1)<<4 + N0;
   print("\nN =");
   print_hex (N, 32);
print ("\nWrite verification:\n");







  for (counter = 0; counter <= N; counter ++){
    if(vect[counter] != counter)
      {
 print_dec(vect[counter]);
 print(" should've been ");
 print_dec(counter);
 print("\n");





      };
  };

print ("Write print:\n");




  for (counter = 0; counter <= N; counter ++)
    {
      print(" ");
      print_hex (vect[counter], 5);


    };

  print("\nEnd of program.\n");


}

}
