// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps



module iob2axil #(
    parameter AXIL_ADDR_W = 21,           // AXI Lite address bus width in bits
    parameter AXIL_DATA_W = 21,           // AXI Lite data bus width in bits
    parameter ADDR_W      = AXIL_ADDR_W,  // IOb address bus width in bits
    parameter DATA_W      = AXIL_DATA_W   // IOb data bus width in bits
) (
    // AXI4 Lite master interface
    output wire                     axil_awvalid_o,
    input  wire                     axil_awready_i,
    output wire [  AXIL_ADDR_W-1:0] axil_awaddr_o,
    output wire [              2:0] axil_awprot_o,
    output wire                     axil_wvalid_o,
    input  wire                     axil_wready_i,
    output wire [  AXIL_DATA_W-1:0] axil_wdata_o,
    output wire [AXIL_DATA_W/8-1:0] axil_wstrb_o,
    input  wire                     axil_bvalid_i,
    output wire                     axil_bready_o,
    input  wire [              1:0] axil_bresp_i,
    output wire                     axil_arvalid_o,
    input  wire                     axil_arready_i,
    output wire [  AXIL_ADDR_W-1:0] axil_araddr_o,
    output wire [              2:0] axil_arprot_o,
    input  wire                     axil_rvalid_i,
    output wire                     axil_rready_o,
    input  wire [  AXIL_DATA_W-1:0] axil_rdata_i,
    input  wire [              1:0] axil_rresp_i,

    // IOb slave interface
    input  wire                iob_valid_i,
    input  wire [  ADDR_W-1:0] iob_addr_i,
    input  wire [  DATA_W-1:0] iob_wdata_i,
    input  wire [DATA_W/8-1:0] iob_wstrb_i,
    output wire                iob_rvalid_o,
    output wire [  DATA_W-1:0] iob_rdata_o,
    output wire                iob_ready_o
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
  assign axil_awprot_o  = 3'd2;

  // write
  assign axil_wvalid_o  = iob_valid_i & |iob_wstrb_i;
  assign axil_wdata_o   = iob_wdata_i;
  assign axil_wstrb_o   = iob_wstrb_i;

  // write response
  assign axil_bready_o  = 1'b1;

  // read address
  assign axil_arvalid_o = iob_valid_i & ~|iob_wstrb_i;
  assign axil_araddr_o  = iob_addr_i;
  assign axil_arprot_o  = 3'd2;

  // read
  assign axil_rready_o  = 1'b1;

endmodule
