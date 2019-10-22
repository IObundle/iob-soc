//Slave ID definition
//`define CACHE 1 //Main memory should be always 1
`define UART 2
//`define CACHE_CTRL 3
`define AUX_MEM 4 //Required the 100 MHZ clock (and not using DDR) to use this memory

//`define DDR //Using the DDR requires CACHE
//`define DDR_INTERCONNECT

//`define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock

`define MAIN_MEM_BASE 3'd1
`define BOOT_MEM_BASE 3'd0
