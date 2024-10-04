// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_iob2wishbone #(
    parameter ADDR_W     = 32,
    parameter DATA_W     = 32,
    parameter READ_BYTES = 4
) (
    `include "iob_iob2wishbone_clk_en_rst_s_port.vs"

    // IOb interface
    input  wire                iob_valid_i,
    input  wire [  ADDR_W-1:0] iob_addr_i,
    input  wire [  DATA_W-1:0] iob_wdata_i,
    input  wire [DATA_W/8-1:0] iob_wstrb_i,
    output wire                iob_rvalid_o,
    output wire [  DATA_W-1:0] iob_rdata_o,
    output wire                iob_ready_o,

    // Wishbone interface
    output wire [  ADDR_W-1:0] wb_addr_o,
    output wire [DATA_W/8-1:0] wb_select_o,
    output wire                wb_we_o,
    output wire                wb_cyc_o,
    output wire                wb_stb_o,
    output wire [  DATA_W-1:0] wb_data_o,
    input  wire                wb_ack_i,
    input  wire [  DATA_W-1:0] wb_data_i
);

  localparam RB_MASK = {1'b0, {READ_BYTES{1'b1}}};

  // IOb auxiliar wires
  wire                iob_valid_r;
  wire [  ADDR_W-1:0] iob_address_r;
  wire [  DATA_W-1:0] iob_wdata_r;
  // Wishbone auxiliar wire
  wire [  DATA_W-1:0] wb_data_r;
  wire [DATA_W/8-1:0] wb_select;
  wire [DATA_W/8-1:0] wb_select_r;
  wire                wb_we;
  wire                wb_we_r;
  wire                wb_ack_r;

  // Logic
  assign wb_addr_o    = iob_valid_i ? iob_addr_i : iob_address_r;
  assign wb_data_o    = iob_valid_i ? iob_wdata_i : iob_wdata_r;
  assign wb_select_o  = iob_valid_i ? wb_select : wb_select_r;
  assign wb_we_o      = iob_valid_i ? wb_we : wb_we_r;
  assign wb_cyc_o     = iob_valid_i ? iob_valid_i : iob_valid_r;
  assign wb_stb_o     = wb_cyc_o;

  assign wb_select    = wb_we ? iob_wstrb_i : (RB_MASK) << (iob_addr_i[1:0]);
  assign wb_we        = |iob_wstrb_i;

  assign iob_rvalid_o = wb_ack_r & (~wb_we_r);
  assign iob_rdata_o  = wb_ack_i ? wb_data_i : wb_data_r;
  assign iob_ready_o  = (~iob_valid_r) | wb_ack_r;

  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_valid (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (wb_ack_i),
      .en_i  (iob_valid_i),
      .data_i(iob_valid_i),
      .data_o(iob_valid_r)
  );
  iob_reg_re #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_addr (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (iob_valid_i),
      .data_i(iob_addr_i),
      .data_o(iob_address_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
  ) iob_reg_iob_data (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (iob_valid_i),
      .data_i(iob_wdata_i),
      .data_o(iob_wdata_r)
  );
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_we (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (iob_valid_i),
      .data_i(wb_we),
      .data_o(wb_we_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
  ) iob_reg_strb (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (iob_valid_i),
      .data_i(wb_select),
      .data_o(wb_select_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
  ) iob_reg_wb_data (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(wb_data_i),
      .data_o(wb_data_r)
  );
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_wb_ack (
      `include "iob_iob2wishbone_clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(wb_ack_i),
      .data_o(wb_ack_r)
  );


endmodule
