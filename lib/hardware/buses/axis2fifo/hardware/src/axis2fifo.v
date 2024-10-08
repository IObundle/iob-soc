// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module axis2fifo #(
    parameter DATA_W     = 0,
    parameter AXIS_LEN_W = 0
) (
    `include "axis2fifo_clk_en_rst_s_port.vs"
    input                   rst_i,
    input                   en_i,
    output [AXIS_LEN_W-1:0] len_o,
    output                  done_o,

    // AXIS I/F
    input  [DATA_W-1:0] axis_tdata_i,
    input               axis_tvalid_i,
    output              axis_tready_o,
    input               axis_tlast_i,

    // FIFO I/F
    input               fifo_full_i,
    output [DATA_W-1:0] fifo_wdata_o,
    output              fifo_write_o
);

  wire axis_word_count_en;

  //tready
  wire axis_tready_nxt;
  assign axis_tready_nxt = (~fifo_full_i) & en_i;
  iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(1'b0)
  ) tready_reg (
      `include "axis2fifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(axis_tready_nxt),
      .data_o(axis_tready_o)
  );

  // tvalid register
  wire axis_tvalid_reg;
  wire in_regs_en;
  assign in_regs_en = axis_tready_o & en_i;
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'b0)
  ) tvalid_reg (
      `include "axis2fifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (in_regs_en),
      .data_i(axis_tvalid_i),
      .data_o(axis_tvalid_reg)
  );

  // tlast register
  wire axis_tlast_reg;
  wire axis_tlast_nxt;
  assign axis_tlast_nxt = axis_tlast_i & axis_tvalid_i;
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'b0)
  ) tlast_reg (
      `include "axis2fifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (in_regs_en),
      .data_i(axis_tlast_nxt),
      .data_o(axis_tlast_reg)
  );

  // tdata register
  wire [DATA_W-1:0] axis_tdata_reg;
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'b0}})
  ) tdata_reg (
      `include "axis2fifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (in_regs_en),
      .data_i(axis_tdata_i),
      .data_o(axis_tdata_reg)
  );

  //word count enable
  assign axis_word_count_en = fifo_write_o & (~done_o);

  //tdata word count
  iob_counter #(
      .DATA_W (AXIS_LEN_W),
      .RST_VAL({AXIS_LEN_W{1'b0}})
  ) word_count_inst (
      `include "axis2fifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (axis_word_count_en),
      .data_o(len_o)
  );

  //tlast detection
  reg axis_tlast_int;
  iob_edge_detect #(
      .EDGE_TYPE("rising"),
      .OUT_TYPE ("step")
  ) tlast_detect (
      `include "axis2fifo_clk_en_rst_s_s_portmap.vs"
      .rst_i     (rst_i),
      .bit_i     (axis_tlast_int),
      .detected_o(done_o)
  );

  reg [DATA_W-1:0] fifo_wdata_int;
  reg fifo_write_int;

  always @* begin
    if (axis_tready_o) begin
      fifo_wdata_int = axis_tdata_i;
      fifo_write_int = axis_tvalid_i & axis_tready_o;
      axis_tlast_int = axis_tlast_i;
    end else begin  // When fifo is full, we need to use the "saved" values
      fifo_wdata_int = axis_tdata_reg;
      fifo_write_int = axis_tvalid_reg & axis_tready_nxt;
      axis_tlast_int = axis_tlast_reg;
    end
  end

  // Output FIFO I/F
  assign fifo_wdata_o = fifo_wdata_int;
  assign fifo_write_o = fifo_write_int;

endmodule
