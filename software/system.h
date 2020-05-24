#define NEEDS_BIT(N, B)     (((unsigned long)N >> B) > 0)

#define BITS_TO_REPRESENT(N)                            \
        (NEEDS_BIT(N,  0) + NEEDS_BIT(N,  1) + \
         NEEDS_BIT(N,  2) + NEEDS_BIT(N,  3) + \
         NEEDS_BIT(N,  4) + NEEDS_BIT(N,  5) + \
         NEEDS_BIT(N,  6) + NEEDS_BIT(N,  7) + \
         NEEDS_BIT(N,  8) + NEEDS_BIT(N,  9) + \
         NEEDS_BIT(N, 10) + NEEDS_BIT(N, 11) + \
         NEEDS_BIT(N, 12) + NEEDS_BIT(N, 13) + \
         NEEDS_BIT(N, 14) + NEEDS_BIT(N, 15) + \
         NEEDS_BIT(N, 16) + NEEDS_BIT(N, 17) + \
         NEEDS_BIT(N, 18) + NEEDS_BIT(N, 19) + \
         NEEDS_BIT(N, 20) + NEEDS_BIT(N, 21) + \
         NEEDS_BIT(N, 22) + NEEDS_BIT(N, 23) + \
         NEEDS_BIT(N, 24) + NEEDS_BIT(N, 25) + \
         NEEDS_BIT(N, 26) + NEEDS_BIT(N, 27) + \
         NEEDS_BIT(N, 28) + NEEDS_BIT(N, 29) + \
         NEEDS_BIT(N, 30) + NEEDS_BIT(N, 31)   \
        )

//Architecural parameters
#define ADDR_W 32
#define N_SLAVES_W BITS_TO_REPRESENT(N_SLAVES)

//
//Memory map
//

//addres of secondary memory:
//SRAM if running from DDR or
//DDR if running from SRAM
#define EXTRA_BASE (1<<31)

#if (USE_SRAM==1 && USE_DDR==1)
#define PBIT 30
#else
#define PBIT 31
#endif

#define UART_BASE (1<<PBIT) |(UART<<(ADDR_W-N_SLAVES_W))


