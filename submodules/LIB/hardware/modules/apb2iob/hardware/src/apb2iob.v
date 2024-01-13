`timescale 1ns / 1ps


//
// APB slave port to IOb master interface

module apb2iob #(
   parameter APB_ADDR_W = 21,          // APB address bus width in bits
   parameter APB_DATA_W = 21,          // APB data bus width in bits
   parameter ADDR_W     = APB_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W     = APB_DATA_W   // IOb data bus width in bits
) (
   // Global signals
   `include "clk_en_rst_s_port.vs"

   // APB slave interface
   `include "apb_s_port.vs"

   // IOb master interface
   `include "iob_m_port.vs"
);

   wire apb_ready_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) apb_ready_reg_inst (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(apb_ready_nxt),
      .data_o(apb_ready_o)
   );
   assign apb_ready_nxt = ~apb_ready_o & iob_ready_i & apb_sel_i & apb_enable_i;
   assign apb_rdata_o = iob_rdata_i;

   assign iob_valid_o = apb_sel_i & apb_enable_i & ~apb_ready_o;
   assign iob_addr_o   = apb_addr_i;
   assign iob_wdata_o  = apb_wdata_i;
   assign iob_wstrb_o  = apb_wstrb_i;

endmodule
