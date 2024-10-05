// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_ctls #(
   parameter W      = 21,
   parameter MODE   = 0,   //trailing (0), leading (1)
   parameter SYMBOL = 0    //search zeros (0), search ones (1)
) (
   input  [      W-1:0] data_i,
   output [$clog2(W):0] count_o
);

   //invert if searching zeros or not
   wire [W-1:0] data_int1;
   generate
      if (SYMBOL == 0) begin : g_zeros
         assign data_int1 = data_i;
      end else begin : g_ones
         assign data_int1 = ~data_i;
      end
   endgenerate

   // reverse if leading symbols or not
   wire [W-1:0] data_int2;
   generate
      if (MODE == 1) begin : g_reverse
         iob_reverse #(W) reverse0 (
            .data_i(data_int1),
            .data_o(data_int2)
         );
      end else begin : g_noreverse
         assign data_int2 = data_int1;
      end
   endgenerate

   //count trailing zeros
   iob_prio_enc #(
      .W   (W + 1),
      .MODE("LOW")
   ) prio_encoder0 (
      .unencoded_i({1'b1, data_int2}),
      .encoded_o  (count_o)
   );

endmodule
