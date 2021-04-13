//data width
`define DATA_W 32
//address width
`define ADDR_W 32
// number of slaves (log2)
`define N_SLAVES_W $clog2(`N_SLAVES)

//init sram/ddr with firmware
`ifdef INIT_MEM
 `ifdef USE_EXTMEM
  `ifdef RUN_EXTMEM
   `define DDR_INIT
  `else
   `define SRAM_INIT
  `endif
 `else //ddr not used
  `define SRAM_INIT
 `endif
`else
 `define LD_FW
`endif

// run modes
`ifdef USE_EXTMEM
 `ifdef RUN_EXTMEM
  `define RUN_EXTMEM_USE_SRAM
 `else
  `define RUN_SRAM_USE_EXTMEM
 `endif
`endif
 
// data bus select bits
`define V_BIT (`REQ_W - 1) //valid bit
`define E_BIT (`REQ_W - (`ADDR_W-`E+1)) //extra mem select bit
`define P_BIT (`REQ_W - (`ADDR_W-`P+1)) //peripherals select bit
`define B_BIT (`REQ_W - (`ADDR_W-`B+1)) //boot controller select bit

