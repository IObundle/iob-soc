// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_gray_counter #(
    parameter W = 1
) (
    `include "iob_gray_counter_clk_en_rst_s_port.vs"

    input rst_i,
    input en_i,

    output [W-1:0] data_o
);

  wire [W-1:0] bin_counter;
  wire [W-1:0] bin_counter_nxt;
  wire [W-1:0] gray_counter;
  wire [W-1:0] gray_counter_nxt;

  assign bin_counter_nxt = bin_counter + 1'b1;

  generate
    if (W > 1) begin : g_width_gt1
      assign gray_counter_nxt = {bin_counter[W-1], bin_counter[W-2:0] ^ bin_counter[W-1:1]};
    end else begin : g_width_eq1
      assign gray_counter_nxt = bin_counter;
    end
  endgenerate

  iob_reg_re #(
      .DATA_W (W),
      .RST_VAL({{(W - 1) {1'd0}}, 1'd1})
  ) bin_counter_reg (
      `include "iob_gray_counter_clk_en_rst_s_s_portmap.vs"

      .rst_i(rst_i),
      .en_i (en_i),

      .data_i(bin_counter_nxt),
      .data_o(bin_counter)
  );

  iob_reg_re #(
      .DATA_W (W),
      .RST_VAL({W{1'd0}})
  ) gray_counter_reg (
      `include "iob_gray_counter_clk_en_rst_s_s_portmap.vs"

      .rst_i(rst_i),
      .en_i (en_i),

      .data_i(gray_counter_nxt),
      .data_o(gray_counter)
  );

  assign data_o = gray_counter;

endmodule
