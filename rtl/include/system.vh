//
// HARDWARE DEFINITIONS
//

//Optional memories (passed as command line macro)
//`define USE_BOOT
`define USE_DDR

// slaves
// minimum 3 slaves: boot, uart and reset
// 1 slave for bootram and/or main RAM memory
// 2 slaves for DDR: cache and cache controller
`define N_SLAVES 5

//bits reserved to identify slave
`define N_SLAVES_W 3

//peripheral address prefixes
`define MAINRAM_BASE 0
`define UART_BASE 1
`define SOFT_RESET_BASE 2
`define CACHE_BASE 3
`define CACHE_CTRL_BASE 4

//address width
`define ADDR_W 32

//data width
`define DATA_W 32

//boot memory address space (log2 of byte size)
`define BOOTROM_ADDR_W 12
`define BOOTRAM_ADDR_W 13

//main memory address space (log2 of byte size)
//must be same as BOOTRAM_ADDR_W if DDR is unused
`define MAINRAM_ADDR_W 13

//use CPU lookahead interface
`define USE_LA_IF
