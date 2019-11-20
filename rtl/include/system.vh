//clock frequencies
//`define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock

//address width
`define ADDR_W 32

//data width
`define DATA_W 32

//write strobe 
`define S_WSTRB_W 4

// boot memory address space (log2)
`define BOOT_ADDR_W 12 //2**10 (1024 long words) * 4 (bytes)

// main memory address space (log2)
`define MEM_ADDR_W 14 //2**12 (4096 long words) * 4 (bytes)

// slaves
`define N_SLAVES 5
`define N_SLAVES_W 3

//memory map
`define CACHE_CTRL_BASE 1
`define UART_BASE 2
`define SOFT_RESET_ADDR 3

//optional hardware
//`define USE_RAM
//`define USE_DDR
