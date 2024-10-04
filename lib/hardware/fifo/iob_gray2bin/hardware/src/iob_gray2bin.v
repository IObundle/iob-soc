// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

// Convert gray encoding to binary
module iob_gray2bin #(
   parameter DATA_W = 4
) (
   input  [DATA_W-1:0] gr_i,
   output [DATA_W-1:0] bin_o
);

   genvar pos;

   generate
      for (pos = 0; pos < DATA_W; pos = pos + 1) begin : gen_bin
         assign bin_o[pos] = ^gr_i[DATA_W-1:pos];
      end
   endgenerate

endmodule
