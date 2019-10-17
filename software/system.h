//When using DDR and not using AUXMEM_BASE
//#define BOOTMEM_BASE    0x00000000
//#define MAINMEM_BASE    0x40000000
//#define UART_BASE       0x80000000
//#define CACHE_CTRL_BASE 0xC0000000

//When not using DDR and using AUXMEM_BASE
#define BOOTMEM_BASE    0x00000000
#define MAINMEM_BASE    0x20000000
#define UART_BASE       0x40000000
#define CACHE_CTRL_BASE 0x60000000
#define AUXMEM_BASE     0x80000000

//#define DDR
