`timescale 1ns / 1ps

module axil2iob #(
   parameter AXIL_ADDR_W = 21,           // AXI Lite address bus width in bits
   parameter AXIL_DATA_W = 21,           // AXI Lite data bus width in bits
   parameter ADDR_W      = AXIL_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W      = AXIL_DATA_W   // IOb data bus width in bits
) (
   // Global signals
   `include "clk_en_rst_s_port.vs"

   // AXI4 Lite slave interface
   `include "axil_s_port.vs"

   // IOb master interface
   `include "iob_m_port.vs"
);

   // COMPUTE AXIL OUTPUTS

   // write address channel
   assign axil_awready_o = iob_ready_i;

   // write channel
   assign axil_wready_o  = iob_ready_i;

   // write response
   assign axil_bresp_o   = 2'b0;
   wire axil_bvalid_nxt;
   //bvalid will toggle in the two situations below:
   assign axil_bvalid_nxt = axil_bvalid_o ^ (((~axil_bvalid_o) & axil_wvalid_i)
                              | (axil_bvalid_o & axil_bready_i & (~axil_wvalid_i)));

   // read address
   assign axil_arready_o = iob_ready_i;

   // read channel
   assign axil_rresp_o = 2'b0;
   wire rvalid_nxt;
   //rvalid will toggle in the two situations below:
   assign rvalid_nxt = axil_rvalid_o ^ (((~axil_rvalid_o) & iob_rvalid_i)
                        | (axil_rvalid_o & (axil_rready_i & (~iob_rvalid_i))));


   // COMPUTE IOb OUTPUTS

   assign iob_valid_o = (axil_wvalid_i & (|axil_wstrb_i)) | axil_arvalid_i;
   assign iob_addr_o = axil_arvalid_i ? axil_araddr_i : axil_awaddr_i;
   assign iob_wdata_o = axil_wdata_i;
   assign iob_wstrb_o = axil_arvalid_i ? {(DATA_W / 8) {1'b0}} : axil_wstrb_i;

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_bvalid (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(axil_bvalid_nxt),
      .data_o(axil_bvalid_o)
   );

   //rvalid register
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_rvalid (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(rvalid_nxt),
      .data_o(axil_rvalid_o)
   );

   iob_reg_e #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'b0}})
   ) iob_reg_rdata (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (iob_rvalid_i),
      .data_i(iob_rdata_i),
      .data_o(axil_rdata_o)
   );

endmodule
