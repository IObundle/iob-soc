`timescale 1ns / 1ps
`include "iob_soc_conf.vh"
`include "bsp.vh"

module iob_soc_sram #(
   parameter DATA_W      = `IOB_SOC_DATA_W,
   parameter SRAM_ADDR_W = `IOB_SOC_SRAM_ADDR_W,
   parameter HEXFILE     = "none"
) (
`ifdef USE_SPRAM
   output                       valid_SPRAM_o,
   output     [SRAM_ADDR_W-3:0] addr_SPRAM_o,
   output     [DATA_W/8-1:0]    wstrb_SPRAM_o,
   output     [DATA_W-1:0]      wdata_SPRAM_o,
   input      [DATA_W-1:0]      rdata_SPRAM_i,
`endif 
   // intruction bus
   input                        i_valid_o,
   input      [SRAM_ADDR_W-3:0] i_addr_o,
   input      [     DATA_W-1:0] i_wdata_o,   //used for booting
   input      [   DATA_W/8-1:0] i_wstrb_o,   //used for booting
   output     [     DATA_W-1:0] i_rdata_i,
   output                       i_rvalid_o,
   output                       i_ready_o,

   // data bus
   input                        d_valid_o,
   input      [SRAM_ADDR_W-3:0] d_addr_o,
   input      [     DATA_W-1:0] d_wdata_o,
   input      [   DATA_W/8-1:0] d_wstrb_o,
   output     [     DATA_W-1:0] d_rdata_i,
   output                       d_rvalid_o,
   output                       d_ready_o,

   `include "clk_en_rst_s_port.vs"
);

`ifdef USE_SPRAM

   wire d_valid_int = i_valid_o ? 1'b0 : d_valid_o;
   assign valid_SPRAM_o = i_valid_o ? i_valid_o : d_valid_o;
   assign addr_SPRAM_o = i_valid_o ? i_addr_o : d_addr_o;
   assign wdata_SPRAM_o = i_valid_o ? i_wdata_o : d_wdata_o;
   assign wstrb_SPRAM_o = i_valid_o ? i_wstrb_o : d_wstrb_o;
   assign d_rdata_i = rdata_SPRAM_i;
   assign i_rdata_i = rdata_SPRAM_i;
`endif

   // reply with ready 
   wire i_rvalid_nxt;
   assign i_rvalid_nxt = i_valid_o & ~(|i_wstrb_o);

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) i_rvalid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(i_rvalid_nxt),
      .data_o(i_rvalid_o)
   );

   wire d_rvalid_nxt;
   assign d_rvalid_nxt = d_valid_o & ~(|d_wstrb_o);

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) d_rvalid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(d_rvalid_nxt),
      .data_o(d_rvalid_o)
   );
   assign i_ready_o = 1'b1;  // SRAM ready is supposed to always be 1 since requests can be continuous
   assign d_ready_o = 1'b1;

endmodule
