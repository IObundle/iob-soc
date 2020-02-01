//
// HARDWARE DEFINITIONS
//

//Optional memories (passed as command line macro)
//`define USE_RAM
`define USE_DDR

// slaves
// minimum 3 slaves: boot, uart and reset
// optional ram, and ddr (cache + cache_ctr)
`define N_SLAVES 5

//bits reserved to identify slave
`define N_SLAVES_W 3

//peripheral address prefixes
`define BOOT_BASE 0
`define UART_BASE 1
`define SOFT_RESET_BASE 2
`define RAM_BASE 3
`define CACHE_BASE 3
`define CACHE_CTRL_BASE 4

//address width
`define ADDR_W 32

//data width
`define DATA_W 32

//boot memory address space (log2 of byte size)
//if no RAM or DDR set to same size as RAM
`define BOOT_ADDR_W 12

//main memory address space (log2 of byte size)
`define RAM_ADDR_W 20

//uart 
`define UART_CLK_FREQ 100000000
