//
// HARDWARE DEFINITIONS
//

//Optional memories (passed as command line macro)
//`define USE_RAM
//`define USE_DDR

//address width
`define ADDR_W 32

//data width
`define DATA_W 32

//main memory address space (log2 of byte size)
`define RAM_ADDR_W 14

//boot memory address space (log2 of byte size)
//if no RAM or DDR set to same size as RAM
`define BOOT_ADDR_W 16

// slaves
`define N_SLAVES 3
`define N_SLAVES_W 3

//memory map
`define BOOT_BASE 0
`define CACHE_BASE 1
`define CACHE_CTRL_BASE 2
`define RAM_BASE 3
`define UART_BASE 4
`define SOFT_RESET_BASE 5

//uart 
`define UART_CLK_FREQ 100000000


