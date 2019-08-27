`define CACHE
`define DDR //Using the DDR requires CACHE
`define DDR_INTERCONNECT
//`define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock
//`define AUX_MEM //Required the 100 MHZ clock (and not using DDR) to use this memory
//`define PICOSOC_UART //Uses the UART from PicoSoc (worse quality), otherwise uses IOB-UART
