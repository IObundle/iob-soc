`define XILINX
`define CACHE
`define DDR //Using the DDR requires CACHE
//`define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock
//`define AUX_MEM //Required the 100 MHZ clock (and not using DDR) to use this memory
`define DDR_INTERCONNECT

`define MAIN_MEM_BASE 3'd1
`define BOOT_MEM_BASE 3'd0
