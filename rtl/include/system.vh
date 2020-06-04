//data width
`define DATA_W 32
//address width
`define ADDR_W 32
// number of slaves (log2)
`define N_SLAVES_W $clog2(`N_SLAVES)

//use SRAM and DDR
`ifdef USE_SRAM
 `ifdef USE_DDR
  `define USE_SRAM_DDR
 `endif
`endif

//split instruction bus
`ifdef USE_SRAM_DDR
 `ifdef USE_BOOT
  `ifdef RUN_DDR
   `define SPLIT_IBUS
  `endif
 `endif
`endif


// DATA BUS NOTABLE BITS
// valid bit
`define V cpu_d_req[`REQ_W-1]
`ifdef USE_SRAM_DDR
// peripheral selection bit
 `define E cpu_d_req[`REQ_W-2]
// peripheral selection bit
 `define P cpu_d_req[`REQ_W-3]
`else
 `define P cpu_d_req[`REQ_W-2]
`endif
