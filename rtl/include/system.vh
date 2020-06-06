//data width
`define DATA_W 32
//address width
`define ADDR_W 32
// number of slaves (log2)
`define N_SLAVES_W $clog2(`N_SLAVES)

//use both memories
`ifdef USE_SRAM
 `ifdef USE_DDR
  `define USE_SRAM_USE_DDR
 `endif
`endif

//
//MODES
//

//1) boot DDR
`ifdef USE_SRAM_USE_DDR
 `ifdef USE_BOOT
  `ifdef RUN_DDR
   `define BOOT_DDR
  `endif
 `endif
`endif

//2) run DDR, use SRAM, no boot
`ifdef USE_SRAM_USE_DDR
 `ifndef USE_BOOT
  `ifdef RUN_DDR
   `define RUN_DDR_USE_SRAM
  `endif
 `endif
`endif

//3) run sram, use ddr, with or without boot
`ifdef USE_SRAM
 `ifdef USE_DDR
  `ifndef RUN_DDR
   `define RUN_SRAM_USE_DDR
  `endif
 `endif
`endif

//4) run ddr, no sram
`ifndef USE_SRAM
 `ifdef USE_DDR
   `define DDR_ONLY
 `endif
`endif

//5) run sram, no ddr
`ifdef USE_SRAM
 `ifndef USE_DDR
  `define SRAM_ONLY
 `endif
`endif





//INSTRUCTION BUS SELECT
`define IBUS_SEL {1'b0, boot}

 
// DATA BUS NOTABLE BITS
// valid bit
`define V cpu_d_req[`REQ_W-1]
`ifdef USE_SRAM_USE_DDR
 `define E cpu_d_req[`REQ_W-2] // extra memory selection bit
 `define P cpu_d_req[`REQ_W-3] // peripheral selection bit
 `define B d_req[`REQ_W-3 -: 2] // boot controller selection bit
 `define S cpu_d_req[`REQ_W-3 : `REQ_W-3-`N_SLAVES_W]// slave select word
`else
 `define P cpu_d_req[`REQ_W-2]// peripheral selection bit
 `define B d_req[`REQ_W-2 -: 2] // boot controller selection bit
 `define S cpu_d_req[`REQ_W-2 : `REQ_W-2-`N_SLAVES_W]// slave select word
`endif

`define DBUS_SEL_BOOT_DDR {1'b0, (`E~^boot)&(~`P), `P}
`define DBUS_SEL_RUN_DDR_USE_SRAM {1'b0, (~`E)&(~`P), `P}
`define DBUS_SEL_RUN_SRAM_USE_DDR {1'b0, (`E)&(~`P), `P}
`define DBUS_SEL_SINGLE_MEM {1'b0, `P}
