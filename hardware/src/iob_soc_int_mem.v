`timescale 1 ns / 1 ps

`include "iob_soc_conf.vh"
`include "iob_utils.vh"

module iob_soc_int_mem #(
   parameter ADDR_W         = 0,
   parameter DATA_W         = 0,
   parameter HEXFILE        = "firmware",
   parameter BOOT_HEXFILE   = "boot",
   parameter SRAM_ADDR_W    = 0,
   parameter BOOTROM_ADDR_W = 0,
   parameter B_BIT          = 0
) (

   output boot,
   output cpu_reset,

   //instruction bus
   input  [ `REQ_W-1:0] i_req_i,
   output [`RESP_W-1:0] i_resp_o,

   //data bus
   input  [ `REQ_W-1:0] d_req_i,
   output [`RESP_W-1:0] d_resp_o,
`ifdef USE_SPRAM
   output                       valid_spram_o,
   output     [SRAM_ADDR_W-3:0] addr_spram_o,
   output     [DATA_W/8-1:0]    wstrb_spram_o,
   output     [DATA_W-1:0]      wdata_spram_o,
   input      [DATA_W-1:0]      rdata_spram_i,
`endif 
   //rom
   output                           rom_r_valid_o,
   output      [BOOTROM_ADDR_W-3:0] rom_r_addr_o,
   input       [DATA_W-1:0]         rom_r_rdata_i,
   //

   //sram
   output                           i_valid_o,
   output      [SRAM_ADDR_W-3:0]    i_addr_o,
   output      [     DATA_W-1:0]    i_wdata_o,
   output      [   DATA_W/8-1:0]    i_wstrb_o,
   input       [     DATA_W-1:0]    i_rdata_i,

   output                           d_valid_o,
   output      [SRAM_ADDR_W-3:0]    d_addr_o,
   output      [     DATA_W-1:0]    d_wdata_o,
   output      [   DATA_W/8-1:0]    d_wstrb_o,
   input       [     DATA_W-1:0]    d_rdata_i,
   //

   `include "clk_en_rst_s_port.vs"
);

   `ifdef USE_SPRAM
      assign ram_d_resp[`RDATA(0)] = rdata_spram_i;
      assign ram_i_resp[`RDATA(0)] = rdata_spram_i;
   
   `else
      assign ram_i_resp[`RDATA(0)] = i_rdata_i;
      assign ram_d_resp[`RDATA(0)] = d_rdata_i;
   `endif 

   assign i_valid_o  = ram_i_req[`VALID(0)];
   assign i_addr_o   = ram_i_req[`ADDRESS(0, SRAM_ADDR_W)-2];
   assign i_wdata_o  = ram_i_req[`WDATA(0)];
   assign i_wstrb_o  = ram_i_req[`WSTRB(0)];

   assign d_valid_o  = ram_d_req[`VALID(0)];
   assign d_addr_o   = ram_d_addr;
   assign d_wdata_o  = ram_d_req[`WDATA(0)];
   assign d_wstrb_o  = ram_d_req[`WSTRB(0)];







   //sram data bus  interface
   wire [     `REQ_W-1:0] ram_d_req;
   wire [    `RESP_W-1:0] ram_d_resp;

   //modified ram address during boot
   wire [SRAM_ADDR_W-3:0] ram_d_addr;


   ////////////////////////////////////////////////////////
   // BOOT HARDWARE
   //
   //boot controller bus to write program in sram
   wire [     `REQ_W-1:0] boot_ctr_req;
   wire [    `RESP_W-1:0] boot_ctr_resp;

   //
   // SPLIT DATA BUS BETWEEN SRAM AND BOOT CONTROLLER
   //
   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(2),
      .P_SLAVES(B_BIT)
   ) data_bootctr_split (
      .clk_i   (clk_i),
      .arst_i  (arst_i),
      // master interface
      .m_req_i (d_req_i),
      .m_resp_o(d_resp_o),

      // slaves interface
      .s_req_o ({boot_ctr_req, ram_d_req}),
      .s_resp_i({boot_ctr_resp, ram_d_resp})
   );


   //
   // BOOT CONTROLLER
   //

   //sram instruction write bus
   wire [ `REQ_W-1:0] ram_w_req;
   wire [`RESP_W-1:0] ram_w_resp;

   iob_soc_boot_ctr #(
      .HEXFILE       ({BOOT_HEXFILE, ".hex"}),
      .DATA_W        (DATA_W),
      .ADDR_W        (ADDR_W),
      .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
      .SRAM_ADDR_W   (SRAM_ADDR_W)
   ) boot_ctr0 (
      .clk_i    (clk_i),
      .arst_i   (arst_i),
      .cke_i    (cke_i),
      .cpu_rst_o(cpu_reset),
      .boot_o   (boot),

      //cpu slave interface
      //no address bus since single address
      .cpu_valid_i(boot_ctr_req[`VALID(0)]),
      .cpu_wdata_i (boot_ctr_req[`WDATA(0)-(DATA_W-2)]),
      .cpu_wstrb_i (boot_ctr_req[`WSTRB(0)]),
      .cpu_rdata_o (boot_ctr_resp[`RDATA(0)]),
      .cpu_rvalid_o(boot_ctr_resp[`RVALID(0)]),
      .cpu_ready_o (boot_ctr_resp[`READY(0)]),

      //sram write master interface
      .sram_valid_o(ram_w_req[`VALID(0)]),
      .sram_addr_o  (ram_w_req[`ADDRESS(0, ADDR_W)]),
      .sram_wdata_o (ram_w_req[`WDATA(0)]),
      .sram_wstrb_o (ram_w_req[`WSTRB(0)]),
      //rom
      .rom_r_valid_o(rom_r_valid_o),
      .rom_r_addr_o(rom_r_addr_o),
      .rom_r_rdata_i(rom_r_rdata_i)
      //
   );

   //
   //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
   //

   //instruction read bus
   wire [     `REQ_W-1:0] ram_r_req;
   wire [    `RESP_W-1:0] ram_r_resp;
   wire [     ADDR_W-1:0] ram_r_addr;
   wire [     ADDR_W-1:0] boot_i_addr;
   wire [     ADDR_W-1:0] i_addr;
   wire [SRAM_ADDR_W-3:0] boot_ram_d_addr;
   wire [SRAM_ADDR_W-3:0] ram_d_addr_int;

   //
   //modify addresses to run  boot program
   //
   localparam boot_offset = -('b1 << BOOTROM_ADDR_W);

   //instruction bus: connect directly but address
   assign ram_r_req[`ADDRESS(0, ADDR_W)] = ram_r_addr;
   assign boot_i_addr = i_req_i[`ADDRESS(0, ADDR_W)] + boot_offset;
   assign i_addr = i_req_i[`ADDRESS(0, ADDR_W)];

   assign ram_r_req[`VALID(0)] = i_req_i[`VALID(0)];
   assign ram_r_addr = boot ? boot_i_addr : i_addr;
   assign ram_r_req[`WRITE(0)] = i_req_i[`WRITE(0)];
   assign i_resp_o[`RESP(0)] = ram_r_resp[`RESP(0)];

   //data bus: just replace address
   assign boot_ram_d_addr = ram_d_req[`ADDRESS(0, SRAM_ADDR_W)-2] + boot_offset[SRAM_ADDR_W-1:2];
   assign ram_d_addr_int = ram_d_req[`ADDRESS(0, SRAM_ADDR_W)-2];
   assign ram_d_addr = boot ? boot_ram_d_addr : ram_d_addr_int;

   //
   //MERGE BOOT WRITE BUS AND CPU READ BUS
   //

   //sram instruction bus
   wire [ `REQ_W-1:0] ram_i_req;
   wire [`RESP_W-1:0] ram_i_resp;

   iob_merge #(
      .N_MASTERS(2)
   ) ibus_merge (
      .clk_i (clk_i),
      .arst_i(arst_i),

      //master
      .m_req_i ({ram_w_req, ram_r_req}),
      .m_resp_o({ram_w_resp, ram_r_resp}),

      //slave
      .s_req_o (ram_i_req),
      .s_resp_i(ram_i_resp)
   );

   //
   // INSTANTIATE RAM
   //
   iob_soc_sram #(
`ifndef IOB_SOC_USE_EXTMEM
`ifdef IOB_SOC_INIT_MEM
      .HEXFILE    (HEXFILE),
`endif
`endif
      .DATA_W     (DATA_W),
      .SRAM_ADDR_W(SRAM_ADDR_W)
   ) int_sram (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
   `ifdef USE_SPRAM
      .valid_spram_o(valid_spram_o),
      .addr_spram_o(addr_spram_o),
      .wstrb_spram_o_o(wstrb_spram_o_o),
      .wdata_spram_o(wdata_spram_o),
      .rdata_spram_i(rdata_spram_i),
   `endif 
      //instruction bus
      .i_valid_i(i_valid_o),
      .i_addr_i  (i_addr_o),
      .i_wdata_i (i_wdata_o),
      .i_wstrb_i (i_wstrb_o),
      .i_rdata_o (),
      .i_rvalid_o(ram_i_resp[`RVALID(0)]),
      .i_ready_o (ram_i_resp[`READY(0)]),

      //data bus
      .d_valid_i(d_valid_o),
      .d_addr_i  (d_addr_o),
      .d_wdata_i (d_wdata_o),
      .d_wstrb_i (d_wstrb_o),
      .d_rdata_o (),
      .d_rvalid_o(ram_d_resp[`RVALID(0)]),
      .d_ready_o (ram_d_resp[`READY(0)])
   );

endmodule
