//clock frequencies
//#define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock

//address width
#define ADDR_W 32

//data width
#define DATA_W 32

// boot memory address space (log2)
#define BOOT_ADDR_W 12 //2**10 (1024 long words) * 4 (bytes)

// main memory address space (log2)
#define MEM_ADDR_W 14 //2**12 (4096 long words) * 4 (bytes)

// slaves
#define N_SLAVES 6
#define N_SLAVES_W 3

//memory map
#define ROM_BASE 0
#define CACHE_BASE 1
#define CACHE_CTRL_BASE 2
#define RAM_BASE 3
#define UART_BASE 4
#define SOFT_RESET_BASE 5

#define UART_CLK_FREQ 100000000 // 100 MHz
#define UART_BAUD_RATE BAUD // Passed as compile command line macro

//Hardware
//#define USE_RAM
//#define USE_DDR
//
