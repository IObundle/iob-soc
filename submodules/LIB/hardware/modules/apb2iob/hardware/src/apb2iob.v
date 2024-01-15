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
   assign apb_ready_o = iob_ready_i;
   assign apb_rdata_o = iob_rdata_i;

   assign iob_valid_o = apb_sel_i & apb_enable_i;
   assign iob_addr_o   = apb_addr_i;
   assign iob_wdata_o  = apb_wdata_i;
   assign iob_wstrb_o  = apb_wstrb_i;

endmodule
