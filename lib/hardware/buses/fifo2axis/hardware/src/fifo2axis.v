// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module fifo2axis #(
    parameter DATA_W     = 0,
    parameter AXIS_LEN_W = 0
) (
    `include "fifo2axis_clk_en_rst_s_port.vs"
    input                  rst_i,
    input                  en_i,
    input [AXIS_LEN_W-1:0] len_i,

    // FIFO I/F
    input               fifo_empty_i,
    output              fifo_read_o,
    input  [DATA_W-1:0] fifo_rdata_i,

    // AXIS I/F
    output              axis_tvalid_o,
    output [DATA_W-1:0] axis_tdata_o,
    input               axis_tready_i,
    output              axis_tlast_o
);

  wire [AXIS_LEN_W-1:0] axis_word_count;

  //FIFO read
  wire                  axis_tvalid_int;

  wire                  pipe_en;
  assign pipe_en = (axis_tready_i | (~axis_tvalid_o)) & en_i;

  assign fifo_read_o = ((~fifo_empty_i) & ((axis_tready_i & axis_tvalid_o) | (~axis_tvalid_o)))
                           & en_i;

  // valid_int register
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
  ) valid_int_reg (
      `include "fifo2axis_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(fifo_read_o),
      .data_o(axis_tvalid_int)
  );

  //FIFO tlast
  wire axis_tlast_nxt;
  wire [AXIS_LEN_W-1:0] len_int = len_i - 1;
  assign axis_tlast_nxt = (axis_word_count == len_int);

  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
  ) axis_tlast_reg (
      `include "fifo2axis_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(axis_tlast_nxt),
      .data_o(axis_tlast_o)
  );

  //tdata word count
  iob_modcnt #(
      .DATA_W (AXIS_LEN_W),
      .RST_VAL({AXIS_LEN_W{1'b1}})  // go to 0 after first enable
  ) word_count_inst (
      `include "fifo2axis_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (fifo_read_o),
      .mod_i (len_int),
      .data_o(axis_word_count)
  );

  //tdata pipe register
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
  ) axis_tdata_reg (
      `include "fifo2axis_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(fifo_rdata_i),
      .data_o(axis_tdata_o)
  );

  //tvalid pipe register
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
  ) axis_tvalid_reg (
      `include "fifo2axis_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(axis_tvalid_int),
      .data_o(axis_tvalid_o)
  );

endmodule
