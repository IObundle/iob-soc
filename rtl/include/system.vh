//data width
`define DATA_W 32
//address width
`define ADDR_W 32
// number of slaves (log2)
`define N_SLAVES_W $clog2(`N_SLAVES)


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
`ifdef USE_DDR
 `ifndef RUN_DDR
  `define RUN_SRAM_USE_DDR
 `endif
`endif

//run ddr
`ifdef USE_DDR
 `ifdef RUN_DDR
  `ifdef USE_BOOT
   `define BOOT_DDR
  `else
   `define RUN_DDR_USE_SRAM
  `endif
 `endif
`endif

 
// DATA BUS NOTABLE BITS

`define E cpu_d_req[`REQ_W-2] // extra memory selection bit
`define P cpu_d_req[`REQ_W-3] // peripheral selection bit
`define S cpu_d_req[`REQ_W-3 : `REQ_W-3-`N_SLAVES_W]// slave select word
`define B d_req[`REQ_W-4] // boot controller select bit

`define IBUS_REQ_BOOT_DDR {cpu_i_req[`valid(0)], boot, cpu_i_req[`REQ_W-3:0]),

`define DBUS_REQ_BOOT_DDR {cpu_d_req[`valid(0)], ~`E^boot, ~`P, cpu_d_req[`REQ_W-4:0]}
`define DBUS_REQ_RUN_DDR_USE_SRAM {cpu_d_req[`valid(0)], ~`E, ~`P, cpu_d_req[`REQ_W-4:0]}
`define DBUS_REQ_RUN_SRAM_USE_DDR {cpu_d_req[`valid(0)], `E, ~(`P|`E), cpu_d_req[`REQ_W-4:0]}
`define DBUS_REQ_RUN_SRAM_NO_DDR {cpu_d_req[`valid(0)], `P, 1'b0, cpu_d_req[`REQ_W-4:0]}

`define PBUS_REQ {pbus_req[`valid(0)], `S, pbus_req[`REQ_W-3-`N_SLAVES_W:0]}
