//clock frequencies
//`define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock

// memory address space (log2)
`define MEM_ADDR_W = 12; 

//memory map
`define BOOT_MEM_BASE 3'd0
`define MAIN_MEM_BASE 3'd1
`define UART_BASE 3'd2
`define CACHE_CTRL_BASE 3

//`define DDR //using the DDR forces using the cache
//`define DDR_INTERCONNECT
