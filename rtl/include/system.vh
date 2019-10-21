`define XILINX

//Slave ID definition
//`define CACHE 1 //Main memory should be always 1
`define UART 2
//`define CACHE_CTRL 3

//IP defines
`define MEC_IF 4  //Interface MEC (mapped registers)
`define INS_IF 5  //Input stream interface
`define OUTS_IF 6  //Output stream interface

//`define DDR //Using the DDR requires CACHE
//`define DDR_INTERCONNECT

//`define CLK_200MHZ //Only when not using DDR, comment this to usea 100 MHz clock

`define MAIN_MEM_BASE 3'd1
`define BOOT_MEM_BASE 3'd0
