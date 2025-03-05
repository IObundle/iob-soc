`timescale 1ns / 1ps



module iob_iob2axil #(
    parameter AXIL_ADDR_W = 21,           // AXI Lite address bus width in bits
    parameter AXIL_DATA_W = 21,           // AXI Lite data bus width in bits
    parameter ADDR_W      = AXIL_ADDR_W,  // IOb address bus width in bits
    parameter DATA_W      = AXIL_DATA_W   // IOb data bus width in bits
) (
    // AXI4 Lite master interface
    output                     axil_awvalid_o,
    input                      axil_awready_i,
    output [  AXIL_ADDR_W-1:0] axil_awaddr_o,
    output                     axil_wvalid_o,
    input                      axil_wready_i,
    output  [  AXIL_DATA_W-1:0] axil_wdata_o,
    output  [AXIL_DATA_W/8-1:0] axil_wstrb_o,
    input                       axil_bvalid_i,
    output                      axil_bready_o,
    input   [              1:0] axil_bresp_i,
    output                      axil_arvalid_o,
    input                       axil_arready_i,
    output  [  AXIL_ADDR_W-1:0] axil_araddr_o,
    input                       axil_rvalid_i,
    output                     axil_rready_o,
    input   [  AXIL_DATA_W-1:0] axil_rdata_i,
    input   [              1:0] axil_rresp_i,

    // IOb slave interface
    `include "iob_s_port.vs"
);

  //
  // COMPUTE IOb OUTPUTS
  //
  assign iob_rvalid_o   = axil_rvalid_i;
  assign iob_rdata_o    = axil_rdata_i;
  assign iob_ready_o    = (~|iob_wstrb_i) ? (axil_wready_i|axil_awready_i): axil_arready_i;

  //
  // COMPUTE AXIL OUTPUTS
  //

  // write address
  assign axil_awvalid_o = iob_valid_i & |iob_wstrb_i;
  assign axil_awaddr_o  = iob_addr_i;

  // write
  assign axil_wvalid_o  = iob_valid_i & |iob_wstrb_i;
  assign axil_wdata_o   = iob_wdata_i;
  assign axil_wstrb_o   = iob_wstrb_i;

  // write response
  assign axil_bready_o  = iob_rready_i;

  // read address
  assign axil_arvalid_o = iob_valid_i & ~|iob_wstrb_i;
  assign axil_araddr_o  = iob_addr_i;

  // read
  assign axil_rready_o  = iob_rready_i;

endmodule
