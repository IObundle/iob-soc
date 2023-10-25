`timescale 1ns / 1ps



module iob2axil #(
   parameter AXIL_ADDR_W = 21,           // AXI Lite address bus width in bits
   parameter AXIL_DATA_W = 21,           // AXI Lite data bus width in bits
   parameter ADDR_W      = AXIL_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W      = AXIL_DATA_W   // IOb data bus width in bits
) (
   //
   // AXI4 Lite master interface
   //
   `include "iob_axil_m_port.vs"

   //
   // IOb slave interface
   //
   `include "iob_s_port.vs"

   // Global signals
   `include "clk_rst_port.vs"
);

   //
   // COMPUTE IOb OUTPUTS
   //
   assign iob_rvalid_o   = axil_rvalid_i;
   assign iob_rdata_o    = axil_rdata_i;
   assign iob_ready_o    = (iob_wstrb_i != {(DATA_W / 8) {1'd0}}) ? axil_wready_i : axil_arready_i;

   //
   // COMPUTE AXIL OUTPUTS
   //

   // write address
   assign axil_awvalid_o = iob_avalid_i & |iob_wstrb_i;
   assign axil_awaddr_o  = iob_addr_i;
   assign axil_awprot_o  = 3'd2;

   // write
   assign axil_wvalid_o  = iob_avalid_i & |iob_wstrb_i;
   assign axil_wdata_o   = iob_wdata_i;
   assign axil_wstrb_o   = iob_wstrb_i;

   // write response
   assign axil_bready_o  = 1'b1;

   // read address
   assign axil_arvalid_o = iob_avalid_i & ~|iob_wstrb_i;
   assign axil_araddr_o  = iob_addr_i;
   assign axil_arprot_o  = 3'd2;

   // read
   assign axil_rready_o  = 1'b1;

endmodule
