// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps
`include "iob_timer_csrs_def.vh"

module timer_core #(
    parameter DATA_W = 32
) (
    input                                                     clk_i,
    input                                                     cke_i,
    input                                                     arst_i,
    input                                                     en_i,
    input                                                     rst_i,
    input                                                     rstrb_i,
    output [`IOB_TIMER_DATA_LOW_W+`IOB_TIMER_DATA_HIGH_W-1:0] time_o
);

  wire [2*DATA_W-1:0] time_counter;

  iob_counter #(
      .DATA_W (2 * DATA_W),
      .RST_VAL(0)
  ) time_counter_cnt (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (rst_i),
      .en_i  (en_i),
      .data_o(time_counter)
  );

  //time counter register
  iob_reg_re #(
      .DATA_W (2 * DATA_W),
      .RST_VAL(0)
  ) time_counter_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (rst_i),
      .en_i  (rstrb_i),
      .data_i(time_counter),
      .data_o(time_o)
  );

endmodule
