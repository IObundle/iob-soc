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

//init sram with firmware, no boot
`ifndef USE_BOOT
 `ifndef USE_DDR
  `define SRAM_INIT
 `else //ddr used
  `ifndef RUN_DDR
   `define SRAM_INIT
  `endif
 `endif
`endif

//init ddr with firmware, no boot
`ifndef USE_BOOT
 `ifdef USE_DDR
  `ifdef RUN_DDR
   `define DDR_INIT
  `endif
 `endif
`endif

//
//MODES
//

//run sram
`ifdef USE_SRAM
 `ifndef RUN_DDR
  `ifdef USE_DDR
   `define RUN_SRAM_USE_DDR
  `endif
 `endif
`endif

//run ddr
`ifdef USE_DDR
 `ifdef RUN_DDR
  `ifndef USE_SRAM
   `define DDR_ONLY
  `else //use SRAM 
   `ifdef USE_BOOT
    `define BOOT_DDR
   `else
    `define RUN_DDR_USE_DDR
   `endif
  `endif
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
 `define S cpu_d_req[`REQ_W-3 : `REQ_W-3-`N_SLAVES_W]// slave select word
`else
 `define P cpu_d_req[`REQ_W-2]// peripheral selection bit
 `define S cpu_d_req[`REQ_W-2 : `REQ_W-2-`N_SLAVES_W]// slave select word
`endif

`define B d_req[`ADDR_P+`SRAM_ADDR_W+1 -: 2] // boot controller select

`define DBUS_SEL_BOOT_DDR {1'b0, (`E~^boot)&(~`P), `P}
`define DBUS_SEL_RUN_DDR_USE_SRAM {1'b0, (~`E)&(~`P), `P}
`define DBUS_SEL_RUN_SRAM_USE_DDR {1'b0, ~`P&`E, ~`P&~`E}
`define DBUS_SEL_SINGLE_MEM {1'b0, `P}
