`timescale 1ns / 1ps
`include "iob_soc_conf.vh"
`include "bsp.vh"

module iob_soc_sram #(
   parameter DATA_W      = `IOB_SOC_DATA_W,
   parameter SRAM_ADDR_W = `IOB_SOC_SRAM_ADDR_W,
   parameter HEXFILE     = "none"
) (
`ifdef USE_SPRAM
   output                       valid_spram_o,
   output     [SRAM_ADDR_W-3:0] addr_spram_o,
   output     [DATA_W/8-1:0]    wstrb_spram_o,
   output     [DATA_W-1:0]      wdata_spram_o,
   input      [DATA_W-1:0]      rdata_spram_i,
`endif 
   // intruction bus
   input                        i_valid_i,
   input      [SRAM_ADDR_W-3:0] i_addr_i,
   input      [     DATA_W-1:0] i_wdata_i,   //used for booting
   input      [   DATA_W/8-1:0] i_wstrb_i,   //used for booting
   output     [     DATA_W-1:0] i_rdata_o,
   output                       i_rvalid_o,
   output                       i_ready_o,

   // data bus
   input                        d_valid_i,
   input      [SRAM_ADDR_W-3:0] d_addr_i,
   input      [     DATA_W-1:0] d_wdata_i,
   input      [   DATA_W/8-1:0] d_wstrb_i,
   output     [     DATA_W-1:0] d_rdata_o,
   output                       d_rvalid_o,
   output                       d_ready_o,

   `include "clk_en_rst_s_port.vs"
);

`ifdef USE_SPRAM
   wire d_valid_int = i_valid_i ? 1'b0 : d_valid_i;
   assign valid_spram_o = i_valid_i ? i_valid_i : d_valid_i;
   assign addr_spram_o = i_valid_i ? i_addr_i : d_addr_i;
   assign wdata_spram_o = i_valid_i ? i_wdata_i : d_wdata_i;
   assign wstrb_spram_o = i_valid_i ? i_wstrb_i : d_wstrb_i;
`endif

   // reply with ready 
   wire i_rvalid_nxt;
   assign i_rvalid_nxt = i_valid_i & ~(|i_wstrb_i);

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
   assign d_rvalid_nxt = d_valid_i & ~(|d_wstrb_i);

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
