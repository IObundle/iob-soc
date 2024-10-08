// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_edge_detect #(
    parameter EDGE_TYPE = "rising",  // "rising", "falling", "both"
    parameter OUT_TYPE  = "step"     // "step", "pulse"
) (
    `include "iob_edge_detect_clk_en_rst_s_port.vs"
    input  rst_i,
    input  bit_i,
    output detected_o
);
  wire bit_int;
  wire bit_int_q;

  generate
    if (EDGE_TYPE == "falling") begin : gen_falling
      assign bit_int = ~bit_i;
      iob_reg_r #(
          .DATA_W (1),
          .RST_VAL(1'b0)
      ) bit_reg (
          `include "iob_edge_detect_clk_en_rst_s_s_portmap.vs"
          .rst_i (rst_i),
          .data_i(bit_int),
          .data_o(bit_int_q)
      );

    end else begin : gen_default_rising
      assign bit_int = bit_i;

      iob_reg_r #(
          .DATA_W (1),
          .RST_VAL(1'b1)
      ) bit_reg (
          `include "iob_edge_detect_clk_en_rst_s_s_portmap.vs"
          .rst_i (rst_i),
          .data_i(bit_int),
          .data_o(bit_int_q)
      );
    end
  endgenerate

  generate
    if (OUT_TYPE == "pulse") begin : gen_pulse
      assign detected_o = bit_int & ~bit_int_q;
    end else begin : gen_step
      wire detected_prev;
      iob_reg_r #(
          .DATA_W(1)
      ) detected_reg (
          `include "iob_edge_detect_clk_en_rst_s_s_portmap.vs"
          .rst_i (rst_i),
          .data_i(detected_o),
          .data_o(detected_prev)
      );
      assign detected_o = detected_prev | (bit_int & ~bit_int_q);
    end
  endgenerate

endmodule
