//
// HARDWARE DEFINITIONS
//

//Optional memories (passed as command line macro)
`define USE_BOOT
`define USE_DDR

// slaves
// minimum 3 slaves: boot, uart and reset
// optional 1 RAM slave for main memory
// DDR needs 2 slaves: cache and cache controller
`define N_SLAVES 6

//bits reserved to identify slave (2**N_SLAVES-1 is reserved)
`define N_SLAVES_W 3

//peripheral address prefixes
`define BOOT_BASE 0
`define UART_BASE 1
`define SOFT_RESET_BASE 2
`define MAINRAM_BASE 3
`define CACHE_BASE 4
`define CACHE_CTRL_BASE 5

//address width
`define ADDR_W 32

//data width
`define DATA_W 32

//boot memory address space (log2 of byte size)
`define BOOTROM_ADDR_W 11
`define BOOTRAM_ADDR_W 13

//main memory address space (log2 of byte size)
//must be same as BOOTRAM_ADDR_W if DDR is unused
`define MAINRAM_ADDR_W 13
