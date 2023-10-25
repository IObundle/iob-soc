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

  //
  // AXI4-Lite interface to IOb
  //
  wire                  iob_rvalid_q;
  wire                  iob_rvalid_e;
  wire                  write_enable;
  wire [ADDR_W-1:0]     addr_q;
  wire                  addr_e;
  wire [ADDR_W-1:0]     addr_d;
  wire                  axil_bvalid_n;
  wire                  axil_bvalid_e;

  assign write_enable  = |axil_wstrb_i;
  assign axil_bvalid_n = axil_wvalid_i;
  assign axil_bvalid_e = axil_bvalid_n | axil_bready_i;
  assign iob_rvalid_e  = iob_rvalid_i | axil_rready_i;

  assign addr_e = axil_arvalid_i | axil_awvalid_i;
  assign addr_d = axil_arvalid_i ? axil_araddr_i : axil_awaddr_i;

  // COMPUTE AXIL OUTPUTS
  // // write address
  assign axil_awready_o  = iob_ready_i;
  // // write
  assign axil_wready_o   = iob_ready_i;
  // // write response
  assign axil_bresp_o    = 2'b0;
  // // read address
  assign axil_arready_o  = iob_ready_i;
  // // read
  assign axil_rdata_o    = iob_rdata_i;
  assign axil_rresp_o    = 2'b0;
  assign axil_rvalid_o   = iob_rvalid_i;

  // COMPUTE IOb OUTPUTS
  assign iob_avalid_o  = (axil_bvalid_n & write_enable) | axil_arvalid_i;
  assign iob_addr_o    = axil_arvalid_i ? axil_araddr_i : (axil_awvalid_i ? axil_awaddr_i : addr_q);
  assign iob_wdata_o   = axil_wdata_i;
  assign iob_wstrb_o   = axil_arvalid_i ? {(DATA_W/8){1'b0}} : axil_wstrb_i;

  // store last read or write address
  iob_reg_e #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_addr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .en_i  (addr_e),
      .data_i(addr_d),
      .data_o(addr_q)
  );

  iob_reg_e #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_rvalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .en_i  (iob_rvalid_e),
      .data_i(iob_rvalid_i),
      .data_o(iob_rvalid_q)
  );

  iob_reg_e #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_bvalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .en_i  (axil_bvalid_e),
      .data_i(axil_bvalid_n),
      .data_o(axil_bvalid_o)
  );

endmodule
