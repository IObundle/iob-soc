//
// HARDWARE DEFINITIONS
//

//Optional memories (passed as command line macro)
`define USE_BOOT
//`define USE_DDR

//main memory address space (log2 of byte size)
`define MAINRAM_ADDR_W 13

// SLAVES
`define N_SLAVES 2
//bits reserved to identify slave
`define N_SLAVES_W 1
//peripheral address prefixes
`define UART_BASE 0
`define SOFT_RESET_BASE 1

//use CPU lookahead interface
`define USE_LA_IF










//////////////////////////////////////////////////////////////////////////
//DO NOT EDIT BEYOND HERE
//
//address width
`define ADDR_W 32
//data width
`define DATA_W 32
//boot rom memory address space (log2 of byte size)
`define BOOTROM_ADDR_W 12

//definitions to be passed to software
//peripheral base addresses
`define UART ((1<<31) | (UART_BASE<<(DATA_W-N_SLAVES_W-1)))
`define SOFT_RESET ((1<<31) | (SOFT_RESET_BASE<<(ADDR_W-N_SLAVES_W-1)))
//internal memory address space (log2 of byte size)
`ifdef USE_DDR
 `define RAM_ADDR_W (BOOTROM_ADDR_W+1)
`else
 `define RAM_ADDR_W MAINRAM_ADDR_W
`endif
