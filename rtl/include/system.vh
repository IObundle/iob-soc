//
// HARDWARE DEFINITIONS
//

//Choose CPU architecture to use
`define PICORV32
//use picorv's lookahead interface
//`define USE_LA_IF

//`define DARKRV

//main memory address space (log2 of byte size)
`define MAINRAM_ADDR_W 13

//`define USE_DDR

//`define USE_BOOT

// SLAVES
`define N_SLAVES 3
//bits reserved to identify slave
//please insert manually...
`define N_SLAVES_W 2

//peripheral address prefixes
`define SRAM_BASE 0
`define SOFT_RESET_BASE 1
//`define DDR_BASE 2
`define UART_BASE 2


//////////////////////////////////////////////////////////////////////////
//DO NOT EDIT BEYOND HERE
//
//address width
`define ADDR_W 32
//memory address width
`define MEM_ADDR_W 31
//peripherals address width
`define P_ADDR_W (`MEM_ADDR_W-`N_SLAVES_W)
//boot ROM address width
`define BOOTROM_ADDR_W 12
//data width
`define DATA_W 32
//concat bus widths
`define IBUS_REQ_W (1+`ADDR_W)
`define DBUS_REQ_W (1+`ADDR_W+`DATA_W+`DATA_W/8)
`define BUS_RESP_W (1+`DATA_W)


//definitions to be passed to software
//peripheral base addresses
`define UART ((1<<31) | (UART_BASE<<(DATA_W-N_SLAVES_W-1)))
`define SOFT_RESET ((1<<31) | (SOFT_RESET_BASE<<(ADDR_W-N_SLAVES_W-1)))
`define DDR ((1<<31) | (DDR_BASE<<(DATA_W-N_SLAVES_W-1)))
`define SRAM ((1<<31) | (SRAM_BASE<<(DATA_W-N_SLAVES_W-1)))
